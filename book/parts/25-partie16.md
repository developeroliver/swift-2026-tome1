# Partie 16 — Concurrence moderne {#partie-16}

## 52. Comprendre la concurrence {#chap-52}

### Synchrone vs asynchrone

Jusqu'ici, tout le code de ce livre était **synchrone** : chaque ligne attend que la précédente ait terminé avant de s'exécuter. Le Projet 5 a introduit une première brèche dans ce modèle : une requête réseau qui prend du temps, sans bloquer le programme pendant l'attente — c'est la définition même de **l'asynchronisme**. Jusqu'à présent, ce livre a géré cela avec des closures `@escaping` et un `DispatchSemaphore` en secours. Cette Partie introduit `async`/`await`, la solution moderne et structurée que Swift propose nativement depuis la version 5.5.

### Threads

Un programme s'exécute sur un ou plusieurs *threads* — des flux d'exécution indépendants, que le système d'exploitation peut faire tourner en parallèle sur les différents cœurs du processeur. Un programme mono-thread exécute une instruction à la fois ; un programme multi-thread peut en exécuter plusieurs simultanément, avec un gain de performance potentiel, mais une complexité bien réelle.

### Race conditions

Une *race condition* survient quand le résultat d'un programme dépend de l'ordre d'exécution imprévisible de plusieurs threads accédant à la **même donnée** :

```swift
var counter = 0

// Deux threads, chacun exécutant ceci "en même temps" :
// counter += 1

// Comportement possible si les deux threads lisent counter (0) avant que l'un des deux
// n'ait eu le temps d'écrire sa nouvelle valeur :
// Thread A lit 0, Thread B lit 0, Thread A écrit 1, Thread B écrit 1
// Résultat final : 1 (au lieu du 2 attendu) — une incrémentation a été "perdue"
```

### Data races

Une *data race* est un cas particulier plus strict et plus dangereux : deux threads accèdent **simultanément** à la même mémoire, dont au moins un en écriture, sans aucune synchronisation. Contrairement à une race condition (qui donne un résultat *incorrect mais défini*), une data race a un comportement **non défini** par le langage — le programme peut planter, corrompre des données de façon imprévisible, ou sembler fonctionner par hasard sur une machine et jamais sur une autre.

> **Ce que Swift apporte** — les langages plus anciens laissent le programmeur entièrement responsable d'éviter les data races, avec des outils manuels (verrous, files d'attente). Swift 6 va plus loin : le compilateur peut **détecter à la compilation** de nombreuses data races potentielles, grâce au système de concurrence structurée (`async`/`await`, `actor`, `Sendable`) détaillé dans le reste de cette Partie. C'est une différence fondamentale avec la plupart des langages : la sécurité de la concurrence devient, au moins partiellement, une garantie du compilateur plutôt qu'une simple discipline du développeur.

<div class="exercise">
<div class="exercise-title">Exercice 52.1</div>
Sans écrire de code : expliquez avec vos propres mots la différence entre une race condition et une data race. Pourquoi la seconde est-elle considérée comme plus grave par le langage ?
</div>

## 53. `async` / `await` {#chap-53}

### Fonctions `async`

Une fonction marquée `async` peut suspendre son exécution en cours de route, pour la reprendre plus tard, sans bloquer le thread pendant l'attente :

```swift
func fetchGreeting() async -> String {
    "Hello, async world!"
}
```

### `await`

Appeler une fonction `async` exige le mot-clé `await` — un signal explicite indiquant un point de suspension possible, exactement comme `try` (chapitre 37) signale un point d'échec possible :

```swift
func showGreeting() async {
    let greeting = await fetchGreeting()
    print(greeting)
}
```

Une fonction `async` ne peut être appelée avec `await` que depuis un autre contexte lui-même asynchrone — une fonction `async`, ou une `Task` (voir plus bas). C'est la même logique de propagation obligatoire déjà vue avec `throws`.

### Réécrire le Projet 5 avec `async`/`await`

Comparez avec le style à base de closures et de `DispatchSemaphore` du Projet 5 :

```swift
func fetchTodo(id: Int) async throws -> Todo {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/\(id)") else {
        throw APIError.invalidURL
    }

    let (data, response) = try await URLSession.shared.data(from: url)

    if let httpResponse = response as? HTTPURLResponse,
       !(200...299).contains(httpResponse.statusCode) {
        throw APIError.serverError(statusCode: httpResponse.statusCode)
    }

    guard
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let id = json?["id"] as? Int,
        let title = json?["title"] as? String,
        let isCompleted = json?["completed"] as? Bool
    else {
        throw APIError.decodingFailed
    }

    return Todo(id: id, title: title, isCompleted: isCompleted)
}
```

`URLSession.shared.data(from:)` est la version `async` moderne de `dataTask(with:completionHandler:)` : elle **suspend** la fonction jusqu'à ce que la réponse arrive, puis reprend l'exécution avec le résultat — sans jamais bloquer le thread pendant l'attente, et sans avoir besoin d'un `DispatchSemaphore` pour « attendre » artificiellement une closure. Notez aussi la combinaison naturelle avec `throws` : une fonction peut être `async throws`, gérant suspension et erreur avec les mêmes outils déjà connus.

### `Task`

Pour appeler une fonction `async` depuis un contexte synchrone (comme le point d'entrée d'un programme en ligne de commande), `Task` crée un nouveau contexte asynchrone :

```swift
Task {
    let todo = try await fetchTodo(id: 1)
    print(todo.title)
}
```

`Task` démarre l'exécution immédiatement, en parallèle du code synchrone qui continue autour d'elle — un point essentiel détaillé au chapitre suivant sur la concurrence structurée.

<div class="exercise">
<div class="exercise-title">Exercice 53.1</div>
Écrivez une fonction <code>async</code> <code>waitAndReturn(_ value: Int) async -> Int</code> qui utilise <code>try? await Task.sleep(for: .seconds(1))</code> pour simuler un délai avant de renvoyer <code>value</code>. Appelez-la depuis un <code>Task</code> et affichez le résultat.
</div>

## 54. Structured Concurrency {#chap-54}

### La hiérarchie des tâches

La **concurrence structurée** garantit qu'une tâche asynchrone ne peut jamais « s'échapper » de la portée où elle a été créée sans que cette portée en soit informée — chaque tâche enfant a un parent, et un parent attend naturellement la fin de ses enfants avant de continuer, un peu comme une fonction attend le retour de celles qu'elle appelle.

### `async let`

`async let` démarre plusieurs opérations asynchrones **en parallèle**, chacune indépendamment, à combiner ensuite :

```swift
func fetchTodo(id: Int) async throws -> Todo { /* comme au chapitre 53 */ fatalError() }

func fetchMultipleTodos() async throws -> (Todo, Todo, Todo) {
    async let first = fetchTodo(id: 1)
    async let second = fetchTodo(id: 2)
    async let third = fetchTodo(id: 3)

    return try await (first, second, third)   // les trois requêtes ont déjà tourné en parallèle
}
```

Les trois appels à `fetchTodo` démarrent **immédiatement et simultanément** dès la ligne `async let` — contrairement à trois `await fetchTodo(...)` successifs, qui attendraient chaque réponse avant de lancer la suivante. Le `await` final ne fait qu'attendre que les trois, déjà en cours, aient terminé.

### Annulation (`cancellation`)

Une tâche peut être annulée — une **coopération**, pas une interruption forcée : la tâche doit elle-même vérifier régulièrement si elle a été annulée, et réagir en conséquence :

```swift
func longRunningTask() async throws {
    for i in 1...1_000_000 {
        try Task.checkCancellation()   // lève CancellationError si la tâche a été annulée
        if i % 100_000 == 0 {
            print("Progress: \(i)")
        }
    }
}

let task = Task {
    try await longRunningTask()
}

task.cancel()   // demande l'annulation ; longRunningTask() doit coopérer pour s'arrêter réellement
```

### Task Groups

Un `TaskGroup` gère un nombre **dynamique** de tâches enfants en parallèle — utile quand ce nombre n'est connu qu'à l'exécution, contrairement à `async let` qui exige un nombre fixe écrit dans le code :

```swift
func fetchAllTodos(ids: [Int]) async throws -> [Todo] {
    try await withThrowingTaskGroup(of: Todo.self) { group in
        for id in ids {
            group.addTask {
                try await fetchTodo(id: id)
            }
        }

        var results: [Todo] = []
        for try await todo in group {
            results.append(todo)
        }
        return results
    }
}
```

Chaque `group.addTask` démarre une tâche enfant en parallèle des autres ; `for try await todo in group` collecte les résultats au fur et à mesure qu'ils arrivent, dans un ordre qui dépend de leur vitesse respective de complétion — pas nécessairement l'ordre d'ajout.

<div class="exercise">
<div class="exercise-title">Exercice 54.1</div>
En vous inspirant de <code>fetchAllTodos</code>, écrivez une fonction qui récupère en parallèle les todos d'identifiants <code>1</code> à <code>5</code> avec un <code>TaskGroup</code>, puis affiche leur nombre total une fois toutes les requêtes terminées.
</div>

## 55. `AsyncSequence` {#chap-55}

### Une séquence dont les éléments arrivent dans le temps

`AsyncSequence` généralise le protocole `Sequence` (qui sous-tend `for-in`, chapitre 7) à des éléments qui n'arrivent pas tous immédiatement, mais au fil du temps — un flux de données plutôt qu'une collection déjà entièrement en mémoire.

### `for await`

```swift
func numbers() -> AsyncStream<Int> {
    AsyncStream { continuation in
        Task {
            for i in 1...5 {
                try? await Task.sleep(for: .milliseconds(200))
                continuation.yield(i)
            }
            continuation.finish()
        }
    }
}

func printNumbers() async {
    for await number in numbers() {
        print(number)   // affiche 1, 2, 3, 4, 5, avec un délai entre chaque
    }
}
```

`for await` ressemble à un `for-in` ordinaire, mais chaque itération peut **suspendre** l'exécution en attendant que l'élément suivant soit disponible — exactement comme un simple `await` suspend une fonction en attendant un résultat unique.

### Flux asynchrones dans la pratique

`AsyncSequence` est notamment utilisé par les API système modernes pour des flux d'événements continus (notifications, changements de valeur observés au fil du temps, lignes lues progressivement d'un fichier volumineux) — des situations où charger tout le résultat en mémoire d'un coup, avant de commencer à le traiter, serait inutile ou impossible.

<div class="exercise">
<div class="exercise-title">Exercice 55.1</div>
Écrivez une fonction <code>countdown() -> AsyncStream&lt;Int&gt;</code> qui émet les nombres de 5 à 1 avec un délai d'une seconde entre chacun, puis termine. Consommez-la avec <code>for await</code> en affichant chaque valeur.
</div>

## 56. Actors {#chap-56}

### Le problème que résolvent les actors

Une `class` (chapitre 22) partagée entre plusieurs tâches concurrentes est exactement le terrain des data races du chapitre 52 : rien n'empêche deux tâches de lire et écrire ses properties simultanément.

```swift
class UnsafeCounter {
    var value = 0
    func increment() { value += 1 }   // dangereux si appelé depuis plusieurs tâches à la fois
}
```

### `actor`

Un `actor` ressemble à une `class` — properties, méthodes, héritage en moins — mais garantit que **une seule tâche à la fois** peut accéder à son état interne. Le compilateur, pas seulement la discipline du développeur, empêche les data races sur cet état :

```swift
actor SafeCounter {
    var value = 0
    func increment() { value += 1 }
}
```

### Isolation

Accéder à l'état d'un `actor` **depuis l'extérieur** exige `await`, même si `increment()` elle-même n'est pas `async` — cet `await` marque le point où l'appelant pourrait devoir attendre que l'actor soit disponible (s'il traite déjà une autre requête au même instant) :

```swift
let counter = SafeCounter()

Task {
    await counter.increment()
    print(await counter.value)
}
```

Cette isolation est **automatique** et **imposée par le compilateur** : il est structurellement impossible d'accéder à `counter.value` sans passer par cette synchronisation — contrairement à `UnsafeCounter`, où rien n'empêchait un accès non protégé.

### `MainActor`

`MainActor` est un actor global spécial représentant le thread principal — celui responsable de l'affichage dans toute application avec interface graphique (essentiel au Tome 2, SwiftUI). Marquer une fonction ou un type `@MainActor` garantit qu'elle s'exécute toujours sur ce thread précis :

```swift
@MainActor
func updateUI(with text: String) {
    print("UI updated: \(text)")   // garanti d'exécuter sur le thread principal
}
```

### Actor reentrancy

Un point subtil : un `actor` **suspendu** en plein milieu d'une méthode (à un point `await`) peut laisser une **autre** tâche s'exécuter sur ce même actor pendant l'attente — l'isolation garantit qu'un seul bloc de code synchrone s'exécute à la fois, pas que l'état de l'actor reste figé entre deux `await` d'une même méthode :

```swift
actor BankAccount {
    var balance = 0

    func deposit(_ amount: Int) async {
        let current = balance
        try? await Task.sleep(for: .seconds(1))   // suspension : une autre tâche peut agir ici
        balance = current + amount             // "current" peut être obsolète si un autre dépôt a eu lieu entre-temps
    }
}
```

> **Piège courant** — la réentrance des actors signifie qu'on ne peut pas supposer que l'état d'un actor est resté inchangé entre deux points `await` d'une même méthode. Relire l'état nécessaire **juste avant** de l'utiliser, plutôt que de faire confiance à une valeur lue avant une suspension, évite cette classe de bugs subtile.

<div class="exercise">
<div class="exercise-title">Exercice 56.1</div>
Transformez <code>UnsafeCounter</code> en <code>actor</code>. Lancez dix <code>Task</code> qui appellent chacune <code>increment()</code> cent fois, attendez-les toutes, puis vérifiez que <code>value</code> vaut exactement 1000 — un résultat qui ne serait pas garanti avec la version <code>class</code>.
</div>

## 57. Sendable {#chap-57}

### Le problème : passer des données entre contextes concurrents

Quand une valeur traverse la frontière entre deux contextes concurrents (par exemple, passée à une `Task` ou à un `actor`), Swift doit garantir qu'aucune data race n'en résultera. `Sendable` est le protocole qui certifie qu'un type peut être partagé en toute sécurité entre plusieurs threads.

### `Sendable`

La plupart des types simples sont automatiquement `Sendable` :

- les `struct` et `enum` dont toutes les properties/valeurs associées sont elles-mêmes `Sendable` (ce qui inclut tous les types de base : `Int`, `String`, `Bool`...) ;
- les types immuables (`let` uniquement) sont de bons candidats naturels, puisqu'ils ne peuvent être modifiés depuis aucun thread après leur création ;
- les `actor` sont automatiquement `Sendable` : leur isolation interne garantit déjà la sécurité.

```swift
struct Point: Sendable {
    let x: Double
    let y: Double
}
```

Une `class` ordinaire, elle, n'est **jamais** automatiquement `Sendable` : sa mutabilité potentiellement partagée (reference semantics, chapitre 25) est précisément le terrain des data races.

### `@Sendable`

Une closure peut aussi être marquée `@Sendable`, garantissant qu'elle ne capture que des valeurs elles-mêmes `Sendable` — nécessaire pour toute closure exécutée dans un contexte concurrent, comme celles passées à `Task` ou `TaskGroup.addTask` :

```swift
func performConcurrently(_ work: @Sendable @escaping () -> Void) {
    Task {
        work()
    }
}
```

### Concurrence stricte

Depuis Swift 6, le compilateur applique par défaut une vérification **stricte** de `Sendable` à travers tout le code — c'est ce qui a produit les avertissements rencontrés au Projet 5, avant d'y fixer `swift-tools-version: 5.10`. Cette vérification stricte transforme une catégorie entière de bugs de concurrence, auparavant détectables seulement à l'exécution (souvent de façon intermittente et difficile à reproduire), en **erreurs de compilation** systématiques.

### Partage sûr de données

La combinaison de tous les outils de cette Partie donne une hiérarchie claire de solutions au partage de données entre tâches concurrentes :

| Besoin | Solution |
|---|---|
| Une valeur immuable, partagée en lecture seule | `struct`/`enum` conforme à `Sendable` |
| Un état mutable, accédé depuis plusieurs tâches | `actor` |
| Du code devant absolument tourner sur le thread principal | `@MainActor` |
| Une closure exécutée dans un nouveau contexte concurrent | `@Sendable` |

Cette Partie 16 est la plus dense du livre, et c'est voulu : la concurrence moderne est l'un des changements les plus profonds de Swift ces dernières années, au cœur du Projet 7 qui suit, et omniprésente dans tout code Swift écrit aujourd'hui — y compris au Tome 2 (SwiftUI, dont le modèle de données repose largement sur `MainActor` et `Sendable`) et au Tome 3 (un serveur Vapor est par nature une application hautement concurrente).

<div class="exercise">
<div class="exercise-title">Exercice 57.1</div>
Expliquez, sans écrire de code, pourquoi une <code>class</code> contenant une seule property <code>let name: String</code> pourrait malgré tout être rendue <code>Sendable</code> manuellement (avec <code>final class Name: Sendable</code>), alors qu'une <code>class</code> ordinaire ne l'est jamais automatiquement. (Indice : relisez la condition « mutabilité potentiellement partagée ».)
</div>
