# Partie 6 — Structures et énumérations {#partie-6}

## 19. Structures {#chap-19}

### Déclaration et properties

Une `struct` regroupe des données (properties) et du comportement (methods) sous un même type. C'est le type le plus utilisé en Swift idiomatique — bien plus que les classes, contrairement à la plupart des langages orientés objet classiques :

```swift
struct Point {
    var x: Double
    var y: Double
}

let origin = Point(x: 0, y: 0)
print(origin.x)   // 0.0
```

### L'initializer memberwise automatique

Remarquez que `Point(x: 0, y: 0)` fonctionne sans qu'aucun initializer n'ait été écrit : Swift **génère automatiquement** un initializer prenant toutes les properties en paramètres, tant qu'aucun initializer personnalisé n'est défini. C'est l'un des plus grands gains de productivité des `struct` par rapport aux `class` (qui n'ont pas cet avantage, voir chapitre 24).

### Methods

```swift
struct Point {
    var x: Double
    var y: Double

    func distance(to other: Point) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        return (dx * dx + dy * dy).squareRoot()
    }
}

let a = Point(x: 0, y: 0)
let b = Point(x: 3, y: 4)
print(a.distance(to: b))   // 5.0
```

### Initializers personnalisés

Dès qu'un initializer personnalisé est écrit, l'initializer memberwise automatique **disparaît** — sauf s'il est défini dans une extension (chapitre 34) :

```swift
struct Circle {
    var radius: Double
    var area: Double

    init(radius: Double) {
        self.radius = radius
        self.area = Double.pi * radius * radius
    }
}

let circle = Circle(radius: 2)
print(circle.area)   // 12.566...
// Circle(radius: 2, area: 12.5)   // ERREUR : cet initializer n'existe plus
```

`self` désigne l'instance en cours de construction — nécessaire ici pour distinguer le paramètre `radius` de la property `radius` du même nom.

### Mutating methods

Une `struct` est un **value type** (détaillé au chapitre 25) : par défaut, ses méthodes ne peuvent pas modifier ses properties. Le mot-clé `mutating` lève cette restriction :

```swift
struct Counter {
    var count = 0

    mutating func increment() {
        count += 1
    }
}

var counter = Counter()
counter.increment()
counter.increment()
print(counter.count)   // 2
```

> **Piège courant** — `mutating func` ne peut être appelée que sur une `struct` stockée dans une **variable** (`var`), jamais dans une constante (`let`) : `let counter = Counter(); counter.increment()` ne compile pas, même si `increment()` semble « juste » incrémenter un compteur. C'est cohérent avec `let` qui interdit toute modification, y compris via une méthode.

### Value semantics

Copier une `struct` crée une copie **totalement indépendante** — modifier la copie n'affecte jamais l'original :

```swift
var original = Counter()
original.increment()

var copy = original       // copie complète et indépendante
copy.increment()

print(original.count)   // 1 : inchangé
print(copy.count)         // 2
```

Ce comportement, qui semble anodin ici, est l'une des plus grandes forces de Swift pour écrire du code prévisible — il sera comparé en détail aux `class` (reference semantics) au chapitre 25.

<div class="exercise">
<div class="exercise-title">Exercice 19.1</div>
Écrivez une <code>struct Rectangle</code> avec des properties <code>width</code> et <code>height</code> (<code>Double</code>), une méthode <code>area() -> Double</code>, et une méthode <code>mutating func scale(by factor: Double)</code> qui multiplie <code>width</code> et <code>height</code> par <code>factor</code>. Vérifiez que copier une instance et la modifier ne touche pas l'originale.
</div>

## 20. Enums {#chap-20}

### Cases

Un `enum` définit un type avec un nombre **fini** de valeurs possibles, appelées *cases* :

```swift
enum Direction {
    case north
    case south
    case east
    case west
}

let heading = Direction.north
```

Une fois le type connu par le compilateur (par exemple via une annotation), le nom du type peut être omis à l'usage :

```swift
var heading: Direction = .north
heading = .south      // Swift déduit qu'il s'agit d'un Direction
```

### Associated values

Chaque case peut porter des données supplémentaires, différentes d'un case à l'autre — bien plus flexible qu'une simple liste de constantes :

```swift
enum Shape {
    case circle(radius: Double)
    case rectangle(width: Double, height: Double)
}

let shape1 = Shape.circle(radius: 5)
let shape2 = Shape.rectangle(width: 3, height: 4)
```

### Raw values

Alternative aux associated values : chaque case peut porter une valeur **fixe** d'un type simple (`String`, `Int`...), pratique pour la sérialisation ou l'affichage :

```swift
enum Weekday: Int {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
}

print(Weekday.tuesday.rawValue)      // 2
let day = Weekday(rawValue: 1)         // Optional(.monday) : l'initializer par raw value échoue si la valeur ne correspond à aucun case
```

> **Note** — contrairement aux associated values, un raw value est **fixe** pour un case donné (`.tuesday` vaut toujours `2`), alors qu'un associated value est fourni à chaque création (`.circle(radius: 5)` puis `.circle(radius: 10)` sont deux valeurs différentes du même case).

### Methods et properties

Un `enum` peut avoir des méthodes et des properties calculées, exactement comme une `struct` :

```swift
enum Direction {
    case north, south, east, west

    func opposite() -> Direction {
        switch self {
        case .north: return .south
        case .south: return .north
        case .east: return .west
        case .west: return .east
        }
    }
}

print(Direction.north.opposite())   // south
```

### Pattern matching avec associated values

Le `switch` peut extraire les associated values directement dans chaque `case` :

```swift
func describe(_ shape: Shape) -> String {
    switch shape {
    case .circle(let radius):
        return "Circle of radius \(radius)"
    case .rectangle(let width, let height):
        return "Rectangle \(width) x \(height)"
    }
}

print(describe(shape1))   // Circle of radius 5.0
print(describe(shape2))    // Rectangle 3.0 x 4.0
```

<div class="exercise">
<div class="exercise-title">Exercice 20.1</div>
Créez un <code>enum PaymentMethod</code> avec trois cases : <code>cash</code>, <code>card(last4Digits: String)</code>, et <code>giftCard(code: String, balance: Double)</code>. Écrivez une fonction <code>summary(for method: PaymentMethod) -> String</code> qui utilise un <code>switch</code> pour décrire chaque méthode de paiement de façon lisible.
</div>

## 21. Enums avancés {#chap-21}

### Enums récursifs et `indirect`

Un `enum` ne peut normalement pas contenir une instance de lui-même comme associated value — sa taille en mémoire ne serait pas calculable (une valeur contenant une valeur contenant une valeur... à l'infini). Le mot-clé `indirect` résout ce problème en stockant l'associated value via une référence plutôt qu'en ligne :

```swift
indirect enum ArithmeticExpression {
    case number(Int)
    case addition(ArithmeticExpression, ArithmeticExpression)
    case multiplication(ArithmeticExpression, ArithmeticExpression)
}

func evaluate(_ expression: ArithmeticExpression) -> Int {
    switch expression {
    case .number(let value):
        return value
    case .addition(let left, let right):
        return evaluate(left) + evaluate(right)
    case .multiplication(let left, let right):
        return evaluate(left) * evaluate(right)
    }
}

// (2 + 3) * 4
let expression = ArithmeticExpression.multiplication(
    .addition(.number(2), .number(3)),
    .number(4)
)
print(evaluate(expression))   // 20
```

`indirect` peut aussi s'appliquer à un seul case plutôt qu'à tout l'enum (`indirect case addition(...)`), si un seul cas a besoin de récursivité.

### Modéliser des états avec des enums

L'un des usages les plus puissants des `enum` en Swift : représenter un **état** dont les variantes sont mutuellement exclusives, chacune avec ses propres données associées. C'est bien plus sûr qu'une combinaison de booléens ou de valeurs optionnelles qui pourraient se contredire :

```swift
enum LoadingState {
    case idle
    case loading
    case loaded(items: [String])
    case failed(error: String)
}

func render(_ state: LoadingState) {
    switch state {
    case .idle:
        print("Waiting to start...")
    case .loading:
        print("Loading...")
    case .loaded(let items):
        print("Loaded \(items.count) items")
    case .failed(let error):
        print("Error: \(error)")
    }
}
```

> **Comparaison** — l'alternative habituelle dans d'autres langages serait quatre variables séparées (`isLoading: Bool`, `items: [String]?`, `errorMessage: String?`...), avec le risque bien réel d'états incohérents (`isLoading = true` alors que `errorMessage` contient aussi quelque chose). Avec un `enum`, un seul état est possible à la fois **par construction** — le compilateur élimine la catégorie de bug entière.

Cette technique de modélisation reviendra dans le Projet 4 qui suit, et sera un pilier du Tome 2 (SwiftUI), où l'état d'une interface est presque toujours représenté ainsi.

<div class="exercise">
<div class="exercise-title">Exercice 21.1</div>
Modélisez le résultat d'une recherche avec un <code>enum SearchResult</code> ayant trois cases : <code>empty</code> (aucun résultat), <code>found(results: [String])</code>, et <code>error(message: String)</code>. Écrivez une fonction qui affiche un message différent et approprié pour chacun des trois cas.
</div>
