# Partie 11 — Gestion des erreurs {#partie-11}

## 37. Error Handling {#chap-37}

### Le protocole `Error`

Vous avez déjà croisé `Error` au Projet 5 : c'est un protocole « marqueur » de la bibliothèque standard, sans aucun requirement — n'importe quel type peut s'y conformer pour représenter une erreur. L'usage idiomatique est un `enum`, dont chaque case représente une façon distincte d'échouer :

```swift
enum ValidationError: Error {
    case tooShort
    case tooLong
    case containsInvalidCharacters
}
```

### `throw` et `throws`

`throw` signale qu'une erreur s'est produite ; une fonction qui peut en émettre une doit être marquée `throws` dans sa signature — visible et explicite, jamais implicite :

```swift
func validate(_ password: String) throws {
    guard password.count >= 8 else {
        throw ValidationError.tooShort
    }
    guard password.count <= 64 else {
        throw ValidationError.tooLong
    }
}
```

Une fonction `throws` qui renvoie aussi une valeur combine les deux : `func parse(_ text: String) throws -> Int`.

### `try`

Appeler une fonction `throws` exige le mot-clé `try` — impossible de l'oublier, encore un exemple de la philosophie « rien de silencieux » de Swift évoquée au chapitre 1 :

```swift
try validate("abc")   // ERREUR DE COMPILATION sans "try"
```

Mais cet appel seul ne suffit pas : une fonction `throws` appelée avec `try` doit elle-même être dans un contexte qui gère l'erreur — soit un bloc `do`/`catch`, soit une fonction elle-même marquée `throws` (l'erreur remonte alors à l'appelant, voir plus bas).

### `do` / `catch`

```swift
do {
    try validate("abc")
    print("Valid password")
} catch {
    print("Invalid password: \(error)")
}
```

À l'intérieur d'un bloc `catch` sans pattern explicite, une constante `error` (de type `any Error`, chapitre 45) est automatiquement disponible. On peut aussi matcher des cas précis, exactement comme un `switch` :

```swift
do {
    try validate("abc")
} catch ValidationError.tooShort {
    print("Password is too short")
} catch ValidationError.tooLong {
    print("Password is too long")
} catch {
    print("Unexpected error: \(error)")
}
```

> **Piège courant** — contrairement à d'autres langages, une erreur Swift non interceptée **ne peut pas** silencieusement continuer l'exécution : soit elle est capturée par un `catch`, soit la fonction courante doit elle-même être `throws` pour la laisser remonter. Il n'existe aucune troisième option — c'est précisément ce qui garantit qu'aucune erreur n'est jamais accidentellement ignorée.

### Propager une erreur vers l'appelant

Une fonction `throws` peut simplement laisser une erreur remonter sans la traiter elle-même :

```swift
func createAccount(password: String) throws -> String {
    try validate(password)         // si validate échoue, createAccount échoue aussi, automatiquement
    return "Account created"
}

do {
    let result = try createAccount(password: "secure_password_123")
    print(result)
} catch {
    print("Failed: \(error)")
}
```

<div class="exercise">
<div class="exercise-title">Exercice 37.1</div>
Écrivez un <code>enum DivisionError: Error</code> avec un case <code>divisionByZero</code>. Écrivez une fonction <code>divide(_ a: Int, by b: Int) throws -> Int</code> qui lève cette erreur si <code>b == 0</code>, sinon renvoie <code>a / b</code>. Appelez-la dans un <code>do</code>/<code>catch</code> avec <code>b = 0</code> puis avec une valeur valide.
</div>

## 38. Gestion avancée {#chap-38}

### `try?`

Déjà utilisé au Projet 5 : `try?` transforme le résultat d'un appel `throws` en un Optionnel — `nil` en cas d'erreur (l'erreur elle-même est perdue), la valeur enveloppée dans `Optional` en cas de succès :

```swift
let result = try? createAccount(password: "abc")
print(result ?? "Failed for some reason")
```

`try?` est idéal quand la nature précise de l'erreur n'a pas d'importance — seul le succès ou l'échec compte, exactement comme `Int("abc")` renvoie `nil` sans détailler pourquoi la conversion a échoué.

### `try!`

`try!` force l'exécution en supposant qu'aucune erreur ne surviendra — si une erreur est malgré tout levée, le programme **plante immédiatement**, comme le `!` du force unwrap (chapitre 17) :

```swift
let result = try! createAccount(password: "a_definitely_valid_password_123")
```

> **Piège courant** — `try!` porte exactement les mêmes risques que le force unwrap, et pour la même raison : il transforme une erreur récupérable en crash non récupérable. Réservez-le aux cas où l'échec est **rigoureusement impossible** par construction (souvent : du code de test, ou des données embarquées dans l'application dont vous contrôlez le format).

### Plusieurs `catch` et pattern matching avancé

Les `catch` peuvent utiliser `where`, exactement comme les `case` d'un `switch` (chapitre 6) :

```swift
enum NetworkError: Error {
    case timeout(seconds: Int)
    case offline
}

func fetchData() throws {
    throw NetworkError.timeout(seconds: 30)
}

do {
    try fetchData()
} catch NetworkError.timeout(let seconds) where seconds > 10 {
    print("Long timeout: \(seconds)s — check your connection")
} catch NetworkError.timeout(let seconds) {
    print("Short timeout: \(seconds)s — retrying")
} catch {
    print("Other error: \(error)")
}
```

### Erreurs personnalisées avec plus de contexte

Un `enum Error` n'est pas limité à des cas vides ou à un simple message : les associated values (chapitre 20) permettent de transporter tout le contexte utile au diagnostic :

```swift
enum FormError: Error {
    case missingField(name: String)
    case invalidFormat(field: String, expected: String)
}

func processForm(email: String?) throws {
    guard let email else {
        throw FormError.missingField(name: "email")
    }
    guard email.contains("@") else {
        throw FormError.invalidFormat(field: "email", expected: "user@example.com")
    }
}
```

Pour un message d'erreur directement lisible par un humain, on peut faire conformer son type d'erreur à `LocalizedError`, un protocole de Foundation avec une property `errorDescription` :

```swift
import Foundation

extension FormError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingField(let name):
            return "The field '\(name)' is required."
        case .invalidFormat(let field, let expected):
            return "The field '\(field)' should look like: \(expected)."
        }
    }
}
```

### Propagation à travers plusieurs niveaux

Une erreur peut traverser plusieurs fonctions `throws` avant d'être finalement traitée — chaque niveau intermédiaire n'a besoin de rien faire de spécial, `throws` suffit à laisser passer :

```swift
func step1() throws { throw FormError.missingField(name: "name") }
func step2() throws { try step1() }
func step3() throws { try step2() }

do {
    try step3()
} catch {
    print("Failed somewhere in the chain: \(error.localizedDescription)")
}
```

<div class="exercise">
<div class="exercise-title">Exercice 38.1</div>
Reprenez <code>DivisionError</code> de l'exercice précédent et ajoutez un case <code>resultTooLarge(value: Int)</code>, levé si le résultat dépasse <code>1000</code>. Faites conformer <code>DivisionError</code> à <code>LocalizedError</code> avec des messages clairs pour chaque cas, puis testez avec plusieurs <code>catch</code> distincts.
</div>
