# Projet 6 — 📦 Swift Package {#projet-6}

Ce projet construit une **vraie bibliothèque Swift réutilisable** : `ValidatorKit`, un petit ensemble de validateurs composables, publiable et importable dans n'importe quel autre projet Swift. C'est l'occasion de mettre en pratique presque tout ce qui a été vu depuis la Partie 8 : protocoles à associated type, generics, existentials `any`, access control, et le tout organisé dans un vrai package multi-cibles.

Le code complet se trouve dans `projects/06-validator-kit/` du dépôt GitHub.

> **Anticipation** — ce projet organise le code en plusieurs *targets* SPM (une bibliothèque, un exécutable de démonstration, une cible de tests) et déclare un *product* dans `Package.swift`. Le fonctionnement complet de Swift Package Manager — dépendances, produits, modules — est le sujet de la Partie 18, juste après. Les tests, eux, utilisent ici `XCTest`, le framework de test historique de Swift, encore très répandu ; le framework moderne **Swift Testing** (`@Test`, `#expect`) sera introduit en Partie 19.

### La structure du package

```text
ValidatorKit/
├── Package.swift
├── Sources/
│   ├── ValidatorKit/            <- la bibliothèque elle-même
│   └── ValidatorKitDemo/         <- un exécutable qui l'utilise, pour la démonstration
└── Tests/
    └── ValidatorKitTests/          <- les tests de la bibliothèque
```

```swift
// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ValidatorKit",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ValidatorKit", targets: ["ValidatorKit"])
    ],
    targets: [
        .target(name: "ValidatorKit"),
        .executableTarget(name: "ValidatorKitDemo", dependencies: ["ValidatorKit"]),
        .testTarget(name: "ValidatorKitTests", dependencies: ["ValidatorKit"])
    ]
)
```

`products: [.library(...)]` est ce qui distingue ce package des projets précédents : c'est cette déclaration qui rend `ValidatorKit` **importable** par un autre package, via `import ValidatorKit`. `platforms: [.macOS(.v13)]` fixe une version minimale de macOS, nécessaire ici pour une fonctionnalité récente du langage utilisée plus bas (les *protocoles à type associé primaire*).

### Le contrat commun : un protocole générique

```swift
public enum ValidationError: Error, Equatable {
    case empty
    case tooShort(minimum: Int)
    case tooLong(maximum: Int)
    case invalidEmail
    case outOfRange
}

public protocol Validator<Value> {
    associatedtype Value
    func validate(_ value: Value) -> Result<Void, ValidationError>
}
```

`protocol Validator<Value>` déclare `Value` comme **associated type primaire** — une syntaxe récente qui permet d'écrire `any Validator<String>` plus loin, plutôt que le seul `any Validator` (chapitre 45) qui perdrait l'information du type de valeur validée. `public` sur chaque déclaration (chapitre 42) est **obligatoire** ici : sans lui, rien ne serait visible depuis `ValidatorKitDemo`, un module différent qui importe `ValidatorKit`.

### Des validateurs concrets

```swift
public struct NotEmptyValidator: Validator {
    public init() {}

    public func validate(_ value: String) -> Result<Void, ValidationError> {
        value.isEmpty ? .failure(.empty) : .success(())
    }
}

public struct RangeValidator<Bound: Comparable>: Validator {
    private let range: ClosedRange<Bound>

    public init(_ range: ClosedRange<Bound>) {
        self.range = range
    }

    public func validate(_ value: Bound) -> Result<Void, ValidationError> {
        range.contains(value) ? .success(()) : .failure(.outOfRange)
    }
}
```

> **Piège courant** — remarquez `public init()` sur `NotEmptyValidator`, alors même que `struct` génère normalement un initializer memberwise automatiquement (chapitre 19). Cet initializer généré automatiquement est **toujours `internal`**, jamais `public` — sans cette ligne explicite, il serait impossible de créer un `NotEmptyValidator()` depuis `ValidatorKitDemo`, un module différent. C'est l'un des pièges d'access control les plus fréquents lors de l'écriture d'une bibliothèque.

`RangeValidator<Bound: Comparable>` est générique (chapitre 35) : le même validateur fonctionne pour un `Int` (un âge), un `Double` (un prix), ou toute autre valeur comparable — comme utilisé dans la démonstration plus bas avec un âge.

### Composer plusieurs validateurs avec `any`

```swift
public struct CombinedValidator<Value>: Validator {
    private let validators: [any Validator<Value>]

    public init(_ validators: [any Validator<Value>]) {
        self.validators = validators
    }

    public func validate(_ value: Value) -> Result<Void, ValidationError> {
        for validator in validators {
            let result = validator.validate(value)
            if case .failure = result {
                return result
            }
        }
        return .success(())
    }
}
```

`[any Validator<Value>]` est un tableau **hétérogène** (chapitre 45) : il peut contenir à la fois un `NotEmptyValidator` et un `LengthValidator`, deux types concrets différents, tant que tous deux valident le même `Value` (ici, `String`). C'est exactement le cas d'usage que `some` (chapitre 44) ne permettrait pas — `CombinedValidator` a précisément besoin de cette hétérogénéité.

### Utiliser la bibliothèque depuis l'exécutable

```swift
import ValidatorKit

func check<V: Validator>(_ validator: V, _ value: V.Value, label: String) {
    switch validator.validate(value) {
    case .success:
        print("✅ \(label): valid")
    case .failure(let error):
        print("❌ \(label): \(error)")
    }
}

let usernameValidator = CombinedValidator<String>([
    NotEmptyValidator(),
    LengthValidator(3...20)
])

check(usernameValidator, "ab", label: "username")             // ❌ tooShort(minimum: 3)
check(usernameValidator, "ada_lovelace", label: "username")     // ✅ valid
```

`import ValidatorKit` fonctionne exactement comme `import Foundation` utilisé depuis le début du livre — la seule différence est que ce module-ci vient d'être écrit dans ce même package, plutôt que fourni par Apple.

### Tester la bibliothèque

```swift
import XCTest
@testable import ValidatorKit

final class ValidatorKitTests: XCTestCase {
    func testNotEmptyValidatorRejectsEmptyString() {
        guard case .failure(let error) = NotEmptyValidator().validate("") else {
            return XCTFail("Expected failure")
        }
        XCTAssertEqual(error, .empty)
    }
}
```

`@testable import` donne accès aux déclarations `internal` de `ValidatorKit` depuis les tests, en plus des déclarations `public` — utile pour tester des détails d'implémentation sans devoir tout rendre public. Chaque test utilise `guard case` plutôt que de comparer directement deux `Result` avec `==` : `Result<Void, ValidationError>` n'est pas `Equatable` (`Void` lui-même ne l'est pas), donc on extrait et compare directement l'erreur en cas d'échec.

### Compiler, exécuter, tester

```bash
cd projects/06-validator-kit
swift build              # compile la bibliothèque et l'exécutable
swift run ValidatorKitDemo  # lance la démonstration
swift test                    # exécute les 6 tests
```

<div class="exercise">
<div class="exercise-title">Exercice — pour aller plus loin</div>
Ajoutez un nouveau validateur <code>PrefixValidator</code> qui vérifie qu'une <code>String</code> commence par un préfixe donné (indice : <code>hasPrefix</code>). Ajoutez-le à <code>usernameValidator</code> dans <code>ValidatorKitDemo</code>, puis écrivez au moins un test pour ce nouveau validateur dans <code>ValidatorKitTests</code>.
</div>
