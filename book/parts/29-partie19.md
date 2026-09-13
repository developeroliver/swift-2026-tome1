# Partie 19 — Tests {#partie-19}

## 62. Tester du Swift {#chap-62}

### Pourquoi tester ?

Un test automatisé vérifie qu'un bout de code se comporte comme prévu, **sans intervention humaine**, et peut être ré-exécuté à volonté — après chaque modification, avant chaque publication, à chaque exécution de CI. Ce livre a déjà pratiqué une forme manuelle de cette discipline : chaque projet, depuis le Jeu de devinettes, a été vérifié avec des scénarios reproductibles (`printf "..." | swift run`). Écrire ces vérifications comme de vrais tests, plutôt que des commandes manuelles, les rend permanentes, automatisables, et immédiatement visibles en cas de régression.

### Unit testing

Un *test unitaire* vérifie une seule unité de comportement — typiquement une fonction ou une méthode — de façon isolée, indépendamment du reste du programme :

```swift
func add(_ a: Int, _ b: Int) -> Int { a + b }

// Un test unitaire vérifie un cas précis :
// "add(2, 3) doit renvoyer 5"
```

Le Projet 6 (`ValidatorKit`) contenait déjà une suite de tests unitaires complète, avec `XCTest` — le framework historique de Swift. Cette Partie introduit **Swift Testing**, le framework moderne recommandé pour tout nouveau code depuis 2024.

### Architecture d'une suite de tests

Une bonne suite de tests vise trois qualités, dans cet ordre de priorité : elle doit être **fiable** (un test qui échoue signale un vrai problème, jamais un hasard), **rapide** (des milliers de tests unitaires doivent s'exécuter en quelques secondes, pas en minutes), et **lisible** (le nom d'un test qui échoue doit, à lui seul, indiquer approximativement où chercher). Le chapitre 64 détaille comment structurer son propre code pour faciliter ces trois qualités.

<div class="exercise">
<div class="exercise-title">Exercice 62.1</div>
Reprenez la fonction <code>isEven(_ number: Int) -> Bool</code> de l'exercice 13.1. Sans encore utiliser de framework de test, écrivez trois lignes <code>assert(...)</code> (une fonction native de Swift) qui vérifient son comportement pour un nombre pair, un nombre impair, et zéro.
</div>

## 63. Swift Testing {#chap-63}

### `@Test`

**Swift Testing** est le framework de test moderne de Swift, intégré nativement à `swift test` depuis Swift 6. Un test est une simple fonction annotée `@Test` :

```swift
import Testing
@testable import Calc

@Test func additionWorks() {
    #expect(add(2, 3) == 5)
}
```

Contrairement à `XCTest` (qui exige des classes héritant de `XCTestCase`, avec des méthodes préfixées `test`), Swift Testing accepte des fonctions libres, sans convention de nommage imposée — plus proche du style Swift idiomatique pratiqué tout au long de ce livre.

### `#expect`

`#expect` est une macro (Partie 17) qui vérifie qu'une condition est vraie, sans arrêter le test en cas d'échec — les vérifications suivantes du même test continuent de s'exécuter, et **toutes** les échecs éventuels sont rapportés :

```swift
@Test func multipleChecks() {
    #expect(add(2, 3) == 5)
    #expect(add(-1, 1) == 0)
    #expect(add(0, 0) == 0)
}
```

`#expect` peut aussi vérifier qu'une erreur est bien levée (chapitre 37) :

```swift
enum DivisionError: Error { case byZero }

func divide(_ a: Int, by b: Int) throws -> Int {
    guard b != 0 else { throw DivisionError.byZero }
    return a / b
}

@Test func divisionByZeroThrows() {
    #expect(throws: DivisionError.self) {
        try divide(10, by: 0)
    }
}
```

### `#require`

`#require`, contrairement à `#expect`, **arrête immédiatement** le test si la condition échoue — approprié quand la suite du test n'aurait aucun sens sans cette garantie (typiquement, extraire un Optionnel dont dépendent toutes les vérifications suivantes) :

```swift
@Test func divisionWorks() throws {
    let result = try #require(try? divide(10, by: 2))
    #expect(result == 5)
}
```

Si `divide(10, by: 2)` échouait de façon inattendue, continuer le test avec un résultat absent n'aurait aucun sens — `#require` évite un crash confus plus loin dans le test, au profit d'un échec clair et immédiat.

### Tests `async`

Un test peut être `async`, exactement comme n'importe quelle fonction (chapitre 53) — indispensable pour tester du code de la Partie 16 :

```swift
@Test func asyncDoublingWorks() async {
    let result = await slowDouble(21)
    #expect(result == 42)
}
```

### Tests paramétrés

`@Test` accepte un argument `arguments:` pour exécuter **le même test** avec plusieurs jeux de données, sans dupliquer le code :

```swift
@Test("Division by zero always throws, regardless of numerator", arguments: [1, 2, 3])
func divisionByZeroThrows(numerator: Int) throws {
    #expect(throws: DivisionError.self) {
        try divide(numerator, by: 0)
    }
}
```

Ce seul test en génère en réalité trois, un par valeur de `arguments`, chacun rapporté individuellement en cas d'échec — bien plus concis que trois fonctions `@Test` séparées ne différant que par une valeur.

<div class="exercise">
<div class="exercise-title">Exercice 63.1</div>
Écrivez une suite de tests Swift Testing pour la fonction <code>isEven</code> de l'exercice précédent, avec un test paramétré couvrant au moins quatre valeurs (deux paires, deux impaires), plutôt que plusieurs fonctions <code>@Test</code> séparées.
</div>

## 64. Tester une architecture {#chap-64}

### Le problème des dépendances externes

Une fonction qui appelle directement un service externe (réseau, disque, horloge système) est difficile à tester : le test devient lent, fragile (dépend d'une connexion internet, d'un fichier présent), et parfois carrément impossible à répéter de façon fiable. La solution, déjà pratiquée au chapitre 32 sans la nommer : dépendre d'un **protocole**, pas d'une implémentation concrète.

### Dependency injection

L'*injection de dépendances* consiste à fournir à une fonction ou un type ce dont il a besoin **de l'extérieur**, plutôt que de le construire lui-même en interne :

```swift
protocol DataStore: Sendable {
    func save(_ text: String)
}

func recordEntry(_ text: String, using store: DataStore) {
    store.save(text)
}
```

`recordEntry` ne sait pas, et n'a pas besoin de savoir, si `store` écrit réellement sur disque, envoie les données sur le réseau, ou ne fait que les garder en mémoire — cette décision appartient entièrement à l'appelant.

### Mocks, stubs et fakes

Trois variantes d'implémentation de test, avec des rôles légèrement différents :

- **Stub** — renvoie des réponses fixes et prédéterminées, sans logique. Utile pour tester un chemin précis sans dépendre d'un vrai comportement.
- **Mock** — enregistre les appels reçus, pour vérifier **après coup** qu'il a été utilisé correctement (bon nombre d'appels, bons arguments).
- **Fake** — une implémentation simplifiée mais **fonctionnelle**, comme une base de données en mémoire remplaçant une vraie base de données persistante.

L'exemple suivant est un *fake* : il se comporte réellement comme un `DataStore`, sans jamais toucher le disque :

```swift
final class InMemoryStore: DataStore, @unchecked Sendable {
    private(set) var savedItems: [String] = []

    func save(_ text: String) {
        savedItems.append(text)
    }
}
```

> **Note** — `@unchecked Sendable` indique au compilateur que **vous** garantissez manuellement l'absence de data race pour ce type, plutôt que de le laisser le vérifier automatiquement (chapitre 57). C'est un échappatoire à utiliser avec précaution en production, mais tout à fait raisonnable ici : `InMemoryStore` n'est utilisé que dans des tests exécutés séquentiellement, jamais dans un contexte réellement concurrent.

### Le test, rendu possible par l'injection

```swift
@Test func recordEntryUsesInjectedStore() {
    let store = InMemoryStore()
    recordEntry("hello", using: store)
    #expect(store.savedItems == ["hello"])
}
```

Ce test s'exécute instantanément, sans disque, sans réseau, et de façon parfaitement reproductible — exactement ce qu'un « vrai » `FileStore` (chapitre 32) ne permettrait pas d'obtenir aussi simplement. C'est cette même logique qui, au Projet 5 et au Projet 7, a isolé chaque requête réseau derrière un protocole (`APIRequest`) : une bonne architecture pour la testabilité et une bonne architecture pour l'évolutivité sont, la plupart du temps, la même chose.

<div class="exercise">
<div class="exercise-title">Exercice — pour aller plus loin</div>
Revenez au Projet 5 (API Client) et identifiez ce qui vous empêcherait aujourd'hui de tester <code>APIClient.send</code> sans faire de vraie requête réseau. Esquissez (sans forcément l'implémenter entièrement) un protocole qui isolerait <code>URLSession</code> derrière une interface testable, à la manière de <code>DataStore</code> ci-dessus.
</div>
