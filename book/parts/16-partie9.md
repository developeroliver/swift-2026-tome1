# Partie 9 — Protocoles {#partie-9}

## 30. Protocoles {#chap-30}

### Déclaration

Un protocole définit un **contrat** : un ensemble de properties et de méthodes qu'un type s'engage à fournir, sans dire comment. C'est l'un des outils les plus centraux de Swift — la Partie 9 tout entière lui est consacrée.

```swift
protocol Greetable {
    var name: String { get }
    func greet() -> String
}
```

### Requirements de properties

Une property requise précise si elle doit être lisible seule (`{ get }`) ou aussi modifiable (`{ get set }`) — peu importe qu'elle soit implémentée comme stored ou computed property par le type conforme :

```swift
protocol HasArea {
    var area: Double { get }         // lecture seule exigée, get+set autorisé aussi
}

struct Square: HasArea {
    var side: Double
    var area: Double { side * side }    // implémentée comme computed property : conforme
}

struct StoredSquare: HasArea {
    var area: Double                       // implémentée comme stored property : conforme aussi
}
```

### Requirements de méthodes

```swift
struct Person: Greetable {
    var name: String

    func greet() -> String {
        "Hello, my name is \(name)"
    }
}

let ada = Person(name: "Ada")
print(ada.greet())   // Hello, my name is Ada
```

### Un protocole comme type

Un protocole peut être utilisé comme un type à part entière — une variable ou un paramètre de fonction peut être « un `Greetable` quelconque », sans savoir précisément lequel :

```swift
func introduce(_ someone: Greetable) {
    print(someone.greet())
}

introduce(ada)   // fonctionne avec n'importe quel type conforme à Greetable
```

Cette capacité — écrire du code qui fonctionne avec « n'importe quoi qui respecte ce contrat » plutôt qu'avec un type concret précis — est au cœur de ce que le chapitre 32 appellera la programmation orientée protocole.

<div class="exercise">
<div class="exercise-title">Exercice 30.1</div>
Définissez un protocole <code>Playable</code> avec une méthode <code>play() -> String</code>. Faites conformer deux structs différentes, <code>Song</code> et <code>Podcast</code>, chacune avec sa propre implémentation de <code>play()</code>. Écrivez une fonction <code>startPlaying(_ item: Playable)</code> qui fonctionne avec les deux.
</div>

## 31. Protocol Extensions {#chap-31}

### Implémentations par défaut

Une extension de protocole (chapitre 34 pour les extensions en général) peut fournir une implémentation **par défaut** d'une méthode — tout type conforme l'obtient gratuitement, sans avoir à l'écrire, sauf s'il préfère la redéfinir :

```swift
protocol Greetable {
    var name: String { get }
    func greet() -> String
}

extension Greetable {
    func greet() -> String {
        "Hello, \(name)!"        // implémentation par défaut
    }
}

struct Robot: Greetable {
    var name: String
    // pas besoin d'implémenter greet() : l'implémentation par défaut suffit
}

let r2d2 = Robot(name: "R2-D2")
print(r2d2.greet())   // Hello, R2-D2!
```

Un type conforme reste libre de fournir sa **propre** implémentation, qui prend alors le pas sur celle par défaut :

```swift
struct Alien: Greetable {
    var name: String

    func greet() -> String {
        "Beep boop, \(name) here"    // remplace l'implémentation par défaut
    }
}
```

### Ajouter des méthodes non déclarées dans le protocole

Une extension de protocole peut aussi ajouter des méthodes **qui ne font pas partie du contrat initial** — utilisables par tout type conforme, construites au-dessus des requirements officiels :

```swift
extension Greetable {
    func shout() -> String {
        greet().uppercased()      // construite à partir de greet(), qui elle est garantie d'exister
    }
}

print(r2d2.shout())   // HELLO, R2-D2!
```

> **Piège courant** — une méthode définie **uniquement** dans une extension de protocole (sans être déclarée dans le protocole lui-même, comme `shout()` ci-dessus) n'est **pas** polymorphique de la même façon que les requirements du protocole : si un type conforme définit sa propre méthode `shout()`, et qu'on appelle `shout()` sur une variable de type `Greetable` (plutôt que sur le type concret), c'est l'implémentation par défaut de l'extension qui s'exécute, pas celle du type concret. Ce comportement (« static dispatch » plutôt que « dynamic dispatch ») est une subtilité avancée du protocol-oriented programming, approfondie au chapitre 32.

<div class="exercise">
<div class="exercise-title">Exercice 31.1</div>
Ajoutez au protocole <code>Playable</code> de l'exercice précédent une extension fournissant une implémentation par défaut de <code>describe() -> String</code> qui renvoie <code>"Now playing"</code>. Vérifiez que <code>Song</code> et <code>Podcast</code> en héritent sans rien écrire de plus.
</div>

## 32. Protocol-oriented programming {#chap-32}

### Composition plutôt qu'héritage

Une `class` ne peut hériter que d'**une seule** superclasse (chapitre 23) — mais un type, quel qu'il soit (`struct`, `enum`, `class`), peut se conformer à **plusieurs** protocoles à la fois. C'est la base de ce que Swift appelle le **protocol-oriented programming** : composer un type à partir de plusieurs petits contrats indépendants, plutôt que de l'inscrire dans une hiérarchie d'héritage rigide.

```swift
protocol Named {
    var name: String { get }
}
protocol Aged {
    var age: Int { get }
}
protocol Employed {
    var jobTitle: String { get }
}

struct Employee: Named, Aged, Employed {
    var name: String
    var age: Int
    var jobTitle: String
}
```

Chaque protocole capture une seule responsabilité. Une fonction peut exiger exactement les capacités dont elle a besoin, ni plus ni moins :

```swift
func birthdayGreeting(for person: Named & Aged) -> String {
    "Happy birthday \(person.name), you're now \(person.age)!"
}

print(birthdayGreeting(for: Employee(name: "Ada", age: 36, jobTitle: "Engineer")))
```

`Named & Aged` est un **type composé** : « n'importe quel type qui respecte à la fois `Named` et `Aged` ». La fonction n'a même pas besoin de connaître `Employed` — elle n'utilise pas cette capacité.

### Inversion de dépendance

Dépendre d'un protocole plutôt que d'un type concret permet d'écrire du code qui ne connaît jamais l'implémentation exacte de ce qu'il manipule — un principe essentiel pour des tests unitaires (Partie 19) et pour remplacer une implémentation sans toucher au code qui l'utilise :

```swift
protocol DataStore {
    func save(_ text: String)
}

struct FileStore: DataStore {
    func save(_ text: String) { /* écrit dans un fichier réel */ }
}

struct InMemoryStore: DataStore {
    var savedItems: [String] = []
    mutating func save(_ text: String) {
        savedItems.append(text)
    }
}

func recordEntry(_ text: String, using store: DataStore) {
    store.save(text)
}
```

`recordEntry` fonctionne identiquement avec un vrai `FileStore` en production, ou un `InMemoryStore` pendant les tests — le code appelant n'a jamais besoin de changer.

### Protocoles vs héritage

| | Héritage de classe | Protocoles |
|---|---|---|
| Nombre | Une seule superclasse | Plusieurs protocoles à la fois |
| Types concernés | `class` uniquement | `struct`, `enum`, `class` |
| Relation | « est un » strict (`Dog` est un `Animal`) | « peut faire » (`Robot` *peut* `Greetable`) |
| Recommandation Swift | À utiliser avec parcimonie | Approche par défaut recommandée |

<div class="exercise">
<div class="exercise-title">Exercice 32.1</div>
Définissez deux protocoles <code>Flyable</code> (méthode <code>fly()</code>) et <code>Swimmable</code> (méthode <code>swim()</code>). Créez une <code>struct Duck</code> conforme aux deux. Écrivez une fonction qui accepte un paramètre de type <code>Flyable & Swimmable</code> et appelle les deux méthodes.
</div>

## 33. Associated Types {#chap-33}

### `associatedtype`

Un protocole peut déclarer un type **générique**, dont le type concret sera choisi par chaque type conforme — c'est un espace réservé, rempli différemment selon l'implémentation :

```swift
protocol Container {
    associatedtype Item
    var items: [Item] { get set }
    mutating func add(_ item: Item)
}

struct IntContainer: Container {
    var items: [Int] = []          // Item devient Int pour ce type
    mutating func add(_ item: Int) {
        items.append(item)
    }
}

struct StringContainer: Container {
    var items: [String] = []        // Item devient String pour ce type
    mutating func add(_ item: String) {
        items.append(item)
    }
}
```

Swift **déduit** le type concret de `Item` à partir de l'implémentation — il n'y a nulle part besoin d'écrire explicitement `typealias Item = Int`, même si c'est possible pour lever une ambiguïté.

### Contraintes sur les associated types

On peut exiger que l'associated type respecte lui-même un protocole, avec `where` ou directement dans sa déclaration :

```swift
protocol Container {
    associatedtype Item: Equatable
    var items: [Item] { get set }

    func contains(_ item: Item) -> Bool
}

extension Container {
    func contains(_ item: Item) -> Bool {
        items.contains(item)      // .contains sur Array exige Equatable, d'où la contrainte
    }
}
```

### Protocoles génériques : la limite de `associatedtype`

Un protocole avec un `associatedtype` **ne peut pas être utilisé directement comme type** de la même façon qu'un protocole ordinaire :

```swift
// var someContainer: Container = IntContainer()
// ERREUR : "Protocol 'Container' can only be used as a generic constraint"
```

C'est une limitation fondamentale, pas un détail : Swift ne peut pas fabriquer un type unique « un `Container` quelconque » puisque la taille et le comportement de `Item` varient d'un type conforme à l'autre. `Container` ne peut être utilisé qu'en **contrainte générique** (chapitre 36) :

```swift
func printAll<C: Container>(_ container: C) {
    for item in container.items {
        print(item)
    }
}
```

Ce point précis sera repris et résolu au chapitre 45 avec `any`, et nuancé au chapitre 44 avec `some` — deux mécanismes conçus spécifiquement pour manipuler des protocoles à associated type dans des contextes où une contrainte générique n'est pas praticable.

<div class="exercise">
<div class="exercise-title">Exercice 33.1</div>
Définissez un protocole <code>Stack</code> avec un <code>associatedtype Element</code>, une méthode <code>push(_ element: Element)</code> et une méthode <code>pop() -> Element?</code>. Implémentez-le dans une <code>struct IntStack</code> utilisant un <code>Array&lt;Int&gt;</code> en interne.
</div>
