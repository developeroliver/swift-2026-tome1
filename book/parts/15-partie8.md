# Partie 8 — Properties {#partie-8}

## 26. Stored Properties {#chap-26}

### Constants et variables

Une *stored property* stocke littéralement une valeur en mémoire — c'est ce que vous utilisez depuis le chapitre 19 sans le nommer explicitement :

```swift
struct Book {
    let title: String       // stored property constante
    var currentPage: Int      // stored property variable
}

var book = Book(title: "Swift 2026", currentPage: 1)
book.currentPage = 42          // OK : currentPage est var
// book.title = "Autre titre"  // ERREUR : title est let
```

### `lazy`

Une property `lazy` n'est calculée **qu'à la première utilisation**, jamais avant — utile quand l'initialisation est coûteuse (calcul long, lecture de fichier) et pas systématiquement nécessaire :

```swift
struct DataImporter {
    init() {
        print("DataImporter initialisé (opération coûteuse)")
    }
}

struct DataManager {
    lazy var importer = DataImporter()
    var data: [String] = []
}

var manager = DataManager()
print("DataManager créé")        // s'affiche en premier
print(manager.importer)            // "DataImporter initialisé..." s'affiche seulement ici
```

> **Piège courant** — une property `lazy` doit obligatoirement être une `var`, jamais une `let` : par définition, sa valeur est assignée après l'initialisation de l'instance (au premier accès), ce qu'une constante interdit. `lazy` n'est pas non plus thread-safe par défaut : si deux threads accèdent à la property en même temps avant sa première initialisation, le comportement n'est pas garanti (voir Partie 16 pour la concurrence).

<div class="exercise">
<div class="exercise-title">Exercice 26.1</div>
Créez une <code>struct Report</code> avec une property <code>lazy var summary: String</code> initialisée par un bloc qui affiche <code>"Computing summary..."</code> avant de renvoyer un texte. Vérifiez, avec des <code>print()</code> avant et après y avoir accédé, que le calcul n'a bien lieu qu'au moment de l'accès.
</div>

## 27. Computed Properties {#chap-27}

### Une valeur calculée à la lecture

Contrairement à une stored property, une *computed property* ne stocke rien : elle recalcule sa valeur à chaque accès, via un bloc de code qui se comporte comme un `get` implicite :

```swift
struct Rectangle {
    var width: Double
    var height: Double

    var area: Double {
        width * height
    }
}

var rectangle = Rectangle(width: 4, height: 5)
print(rectangle.area)   // 20.0
rectangle.width = 10
print(rectangle.area)    // 50.0 : recalculé automatiquement
```

### `get` et `set`

Une computed property peut aussi être **modifiable**, en définissant explicitement un `get` et un `set` :

```swift
struct Temperature {
    var celsius: Double

    var fahrenheit: Double {
        get {
            celsius * 9 / 5 + 32
        }
        set {
            celsius = (newValue - 32) * 5 / 9
        }
    }
}

var temp = Temperature(celsius: 20)
print(temp.fahrenheit)     // 68.0
temp.fahrenheit = 32
print(temp.celsius)          // 0.0
```

`newValue` est le nom implicite donné à la valeur assignée dans un `set` — on peut le renommer (`set(newFahrenheit) { ... }`), mais l'usage idiomatique garde le nom par défaut.

> **Piège courant** — une computed property ne peut **jamais** être une `let` : puisqu'elle n'a pas de mémoire propre où stocker quoi que ce soit, la notion même de « constante » n'a pas de sens pour elle. On contrôle plutôt son immuabilité en omettant le `set` (property en lecture seule, comme `area` plus haut).

<div class="exercise">
<div class="exercise-title">Exercice 27.1</div>
Ajoutez à <code>Rectangle</code> une computed property <code>perimeter: Double</code> (lecture seule), puis une computed property modifiable <code>isSquare: Bool</code> dont le <code>set</code> ajuste <code>height</code> pour qu'elle égale <code>width</code> quand on lui assigne <code>true</code>.
</div>

## 28. Property Observers {#chap-28}

### `willSet` et `didSet`

Un *property observer* exécute du code **autour** d'un changement de valeur d'une stored property, sans transformer la property en computed property — la valeur continue d'être réellement stockée :

```swift
struct Player {
    var score: Int = 0 {
        willSet {
            print("Score will change from \(score) to \(newValue)")
        }
        didSet {
            print("Score changed from \(oldValue) to \(score)")
            if score > oldValue {
                print("Points gained!")
            }
        }
    }
}

var player = Player()
player.score = 10
// Score will change from 0 to 10
// Score changed from 0 to 10
// Points gained!
```

`willSet` reçoit implicitement `newValue` (la future valeur), `didSet` reçoit implicitement `oldValue` (l'ancienne valeur) — dans les deux blocs, `score` lui-même désigne la valeur au moment où le bloc s'exécute (l'ancienne dans `willSet`, la nouvelle dans `didSet`).

> **Piège courant** — assigner une valeur à la property **à l'intérieur** de son propre `didSet` redéclenche l'observer (sauf assignation à une valeur strictement identique, qui elle est ignorée). Un `didSet` qui réassigne systématiquement la même property sans condition peut ainsi créer une boucle infinie ; ajoutez toujours une condition de sortie si vous modifiez la property depuis son propre observer.

Les property observers sont surtout utiles pour réagir à un changement (valider une valeur, notifier un autre composant, déclencher un rafraîchissement d'affichage — un mécanisme central de SwiftUI, abordé au Tome 2) plutôt que pour transformer la valeur elle-même, rôle que jouent les computed properties.

<div class="exercise">
<div class="exercise-title">Exercice 28.1</div>
Ajoutez à <code>Player</code> une property <code>lives: Int = 3</code> avec un <code>didSet</code> qui affiche <code>"Game over!"</code> dès que <code>lives</code> atteint <code>0</code>.
</div>

## 29. Type Properties {#chap-29}

### `static`

Une *type property* appartient au **type lui-même**, pas à une instance particulière — il n'en existe qu'une seule copie, partagée par toutes les instances :

```swift
struct Circle {
    static let numberOfSides = 0        // partagée par tous les Circle, pas de copie par instance
    var radius: Double
}

print(Circle.numberOfSides)   // 0 : accès via le type, pas via une instance
```

`static` fonctionne aussi bien pour des properties calculées et des méthodes :

```swift
struct Constants {
    static let appName = "Swift 2026"

    static func greeting() -> String {
        "Welcome to \(appName)"
    }
}

print(Constants.greeting())   // Welcome to Swift 2026
```

Un cas d'usage très fréquent : un compteur global partagé entre toutes les instances d'un type, comme un identifiant auto-incrémenté :

```swift
struct User {
    static var nextID = 1
    let id: Int
    let name: String

    init(name: String) {
        self.id = User.nextID
        self.name = name
        User.nextID += 1
    }
}

let user1 = User(name: "Ada")
let user2 = User(name: "Grace")
print(user1.id, user2.id)   // 1 2
```

### `class` (pour les type properties redéfinissables)

Pour une `class` uniquement, `class` remplace `static` quand on veut qu'une sous-classe puisse **redéfinir** la property calculée (une redéfinition impossible avec `static`, qui se comporte comme `final` implicitement) :

```swift
class Vehicle {
    class var maxSpeed: Double {
        120
    }
}

class SportsCar: Vehicle {
    override class var maxSpeed: Double {
        320
    }
}

print(Vehicle.maxSpeed)      // 120
print(SportsCar.maxSpeed)     // 320
```

Cette possibilité de redéfinition n'existe que pour les computed type properties (`class var`) — une type *stored* property (`static var` de valeur simple) reste toujours `static`, y compris dans une `class`.

<div class="exercise">
<div class="exercise-title">Exercice 29.1</div>
Ajoutez à une <code>struct Product</code> une <code>static var totalProductsCreated = 0</code>, incrémentée dans l'initializer de chaque instance créée. Créez trois produits et affichez le compteur final via <code>Product.totalProductsCreated</code>.
</div>
