# Partie 7 — Classes et références {#partie-7}

## 22. Classes {#chap-22}

### Création

Une `class` ressemble beaucoup à une `struct` en surface — properties, methods — mais avec une différence fondamentale de comportement détaillée au chapitre 25 : c'est un **reference type**.

```swift
class Vehicle {
    var speed: Double = 0

    func accelerate(by amount: Double) {
        speed += amount
    }
}

let car = Vehicle()
car.accelerate(by: 50)
print(car.speed)   // 50.0
```

> **Note** — contrairement à une `struct`, les méthodes d'une `class` qui modifient ses properties n'ont **pas besoin** du mot-clé `mutating`. C'est une conséquence directe de la reference semantics : `car` est une référence vers l'instance, pas l'instance elle-même, donc modifier ses properties ne remet jamais en cause l'identité de `car`.

### Properties et methods

La syntaxe des properties et des méthodes est identique à celle des `struct` :

```swift
class BankAccount {
    var balance: Double = 0
    let owner: String

    init(owner: String) {
        self.owner = owner
    }

    func deposit(_ amount: Double) {
        balance += amount
    }

    func withdraw(_ amount: Double) -> Bool {
        guard balance >= amount else { return false }
        balance -= amount
        return true
    }
}
```

### Reference semantics

C'est ici que `class` diverge radicalement de `struct` : copier une référence de classe **ne copie pas l'instance**, elle crée un second nom pour la **même** instance :

```swift
let account = BankAccount(owner: "Ada")
account.deposit(100)

let sameAccount = account       // pas une copie : sameAccount et account pointent vers le même objet
sameAccount.deposit(50)

print(account.balance)          // 150.0 : la modification via sameAccount est visible via account aussi
```

Ce comportement sera comparé en détail à celui des `struct` au chapitre 25 — retenez pour l'instant la règle simple : **`class` = référence partagée, `struct` = copie indépendante**.

<div class="exercise">
<div class="exercise-title">Exercice 22.1</div>
Créez une <code>class Counter</code> avec une property <code>count: Int = 0</code> et une méthode <code>increment()</code>. Créez une instance, assignez-la à une seconde constante, incrémentez via la seconde, et vérifiez que la première constante voit aussi le changement.
</div>

## 23. Héritage {#chap-23}

### Classes parent et enfant

Une `class` peut hériter d'une autre, récupérant automatiquement toutes ses properties et méthodes :

```swift
class Animal {
    let name: String

    init(name: String) {
        self.name = name
    }

    func makeSound() -> String {
        "..."
    }
}

class Dog: Animal {
    func fetch() -> String {
        "\(name) fetches the ball!"
    }
}

let dog = Dog(name: "Rex")
print(dog.name)          // héritée d'Animal : "Rex"
print(dog.fetch())        // propre à Dog
```

`Dog` est une **sous-classe** (*subclass*) d'`Animal`, sa **superclasse** (*superclass*). Seules les `class` supportent l'héritage — ni les `struct`, ni les `enum` ne le peuvent, ce qui est l'une des raisons pour lesquelles Swift encourage la composition via les protocoles (Partie 9) plutôt que l'héritage pour la plupart des cas.

### `override`

Une sous-classe peut **redéfinir** une méthode héritée avec `override` — obligatoire, jamais implicite, pour éviter qu'une redéfinition accidentelle passe inaperçue :

```swift
class Cat: Animal {
    override func makeSound() -> String {
        "Meow!"
    }
}

let cat = Cat(name: "Whiskers")
print(cat.makeSound())   // Meow!
```

> **Piège courant** — oublier `override` en redéfinissant une méthode du parent est une **erreur de compilation**, pas un oubli silencieux (« Overriding declaration requires an 'override' keyword »). À l'inverse, écrire `override` sur une méthode qui ne redéfinit en réalité rien (faute de frappe dans le nom, signature légèrement différente) est *aussi* une erreur de compilation. Ce garde-fou dans les deux sens est une protection précieuse.

### `super`

`super` permet d'appeler l'implémentation du parent depuis la sous-classe, pour l'étendre plutôt que la remplacer entièrement :

```swift
class Bird: Animal {
    override func makeSound() -> String {
        let base = super.makeSound()
        return "Tweet! (base sound was: \(base))"
    }
}
```

### `final`

`final` interdit qu'une classe soit sous-classée, ou qu'une méthode/property soit redéfinie :

```swift
final class Configuration {
    // ...
}
// class CustomConfiguration: Configuration { }   // ERREUR : Configuration est final

class Base {
    final func criticalMethod() { }
}
// class Sub: Base {
//     override func criticalMethod() { }   // ERREUR : criticalMethod est final
// }
```

Au-delà de l'intention de conception, `final` a aussi un intérêt de **performance** : le compilateur peut résoudre l'appel à la méthode directement à la compilation plutôt qu'à l'exécution (voir chapitre 66), puisqu'aucune sous-classe ne peut la redéfinir.

<div class="exercise">
<div class="exercise-title">Exercice 23.1</div>
Créez une classe <code>Shape</code> avec une méthode <code>area() -> Double</code> renvoyant <code>0</code>, puis une sous-classe <code>Square</code> avec une property <code>side: Double</code> qui redéfinit <code>area()</code> pour renvoyer le carré du côté. Marquez <code>Square</code> en <code>final</code>.
</div>

## 24. Initialisation {#chap-24}

### Pas d'initializer memberwise automatique

Contrairement aux `struct` (chapitre 19), une `class` **n'obtient jamais** d'initializer memberwise automatique. Toute property sans valeur par défaut doit être initialisée explicitement dans un `init` :

```swift
class Point {
    var x: Double
    var y: Double

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
```

### Initializer par défaut

Si **toutes** les properties ont une valeur par défaut, Swift fournit un initializer sans arguments — mais toujours pas d'initializer memberwise :

```swift
class Settings {
    var isDarkMode: Bool = false
    var fontSize: Int = 14
}

let settings = Settings()   // OK : init() sans argument
```

### Failable initializers

Un initializer peut échouer et renvoyer `nil` plutôt qu'une instance, avec `init?` :

```swift
class Percentage {
    let value: Double

    init?(value: Double) {
        guard (0...100).contains(value) else { return nil }
        self.value = value
    }
}

let valid = Percentage(value: 50)      // Optional(Percentage)
let invalid = Percentage(value: 150)    // nil
```

### `required`

`required` impose que **toute** sous-classe fournisse cet initializer (avec sa propre implémentation, ou en héritant de celle du parent) :

```swift
class Document {
    let title: String

    required init(title: String) {
        self.title = title
    }
}

class Report: Document {
    required init(title: String) {
        super.init(title: title)
    }
}
```

### `convenience`

Un initializer `convenience` doit obligatoirement appeler un autre initializer de **la même classe** (jamais directement `super.init`), généralement pour offrir une façon simplifiée de construire une instance :

```swift
class Rectangle {
    var width: Double
    var height: Double

    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    convenience init(side: Double) {
        self.init(width: side, height: side)   // un carré est un rectangle particulier
    }
}

let square = Rectangle(side: 4)
print(square.width, square.height)   // 4.0 4.0
```

### Héritage de l'initialisation

Une sous-classe qui ajoute ses propres properties doit initialiser **d'abord** celles-ci, **puis** appeler `super.init` :

```swift
class Animal {
    let name: String
    init(name: String) {
        self.name = name
    }
}

class Dog: Animal {
    let breed: String

    init(name: String, breed: String) {
        self.breed = breed          // 1. initialiser les properties propres à Dog
        super.init(name: name)        // 2. seulement ensuite, déléguer au parent
    }
}
```

> **Piège courant** — inverser l'ordre (appeler `super.init` avant que toutes les properties de la sous-classe soient initialisées) est une erreur de compilation. La règle de Swift est stricte et non négociable : une instance doit être **complètement** initialisée, du bas de la hiérarchie vers le haut, avant qu'on puisse l'utiliser — y compris via `self` passé à `super.init`.

<div class="exercise">
<div class="exercise-title">Exercice 24.1</div>
Créez une classe <code>Person</code> avec <code>name: String</code> et un <code>init(name:)</code>, puis une sous-classe <code>Employee</code> ajoutant <code>salary: Double</code>, avec son propre <code>init(name:salary:)</code> qui appelle <code>super.init</code>. Ajoutez à <code>Employee</code> un <code>convenience init(name:)</code> qui fixe un salaire par défaut de <code>0</code>.
</div>

## 25. Value vs Reference {#chap-25}

### Le principe

C'est l'une des distinctions les plus importantes de tout le langage :

```text
struct → value semantics  (copie indépendante)
enum   → value semantics  (copie indépendante)
class  → reference semantics (référence partagée)
```

### Copying

```swift
struct PointStruct { var x: Int }
class PointClass { var x: Int; init(x: Int) { self.x = x } }

// Value semantics (struct)
var s1 = PointStruct(x: 1)
var s2 = s1              // copie complète
s2.x = 99
print(s1.x, s2.x)          // 1 99 : indépendants

// Reference semantics (class)
let c1 = PointClass(x: 1)
let c2 = c1               // même instance, deux noms
c2.x = 99
print(c1.x, c2.x)           // 99 99 : partagés
```

### Mutations et paramètres de fonction

Cette différence se propage aux fonctions : passer une `struct` en paramètre passe une copie (d'où le besoin d'`inout` pour la modifier, chapitre 14), tandis que passer une `class` transmet la référence, et toute modification à l'intérieur de la fonction est visible à l'extérieur :

```swift
func resetStruct(_ point: inout PointStruct) {
    point.x = 0
}
func resetClass(_ point: PointClass) {
    point.x = 0     // pas besoin d'inout : point est déjà une référence
}

var myStruct = PointStruct(x: 5)
resetStruct(&myStruct)
print(myStruct.x)   // 0

let myClass = PointClass(x: 5)
resetClass(myClass)
print(myClass.x)     // 0, sans inout
```

### Identité vs égalité

Deux `class` peuvent avoir un contenu identique sans être la **même** instance. L'opérateur `===` (à ne pas confondre avec `==`) teste l'**identité** — « est-ce littéralement le même objet en mémoire ? » :

```swift
let a = PointClass(x: 1)
let b = PointClass(x: 1)
let c = a

print(a === b)   // false : deux instances différentes, même si leur contenu est égal
print(a === c)   // true : c est une référence vers la même instance que a
```

Cette question n'a tout simplement pas de sens pour une `struct` : deux `struct` avec le même contenu **sont** égales, il n'y a pas d'« identité » séparée du contenu à comparer.

### Copy-on-write

Si les `struct` sont toujours copiées « en valeur » conceptuellement, Swift ne duplique pas réellement leurs données en mémoire à chaque copie — ce serait extrêmement coûteux pour un grand tableau, par exemple. Les collections standard (`Array`, `Dictionary`, `Set`) utilisent une optimisation appelée **copy-on-write** : la copie partage la mémoire de l'original tant qu'aucune des deux n'est modifiée, et la duplication réelle n'a lieu qu'au moment précis d'une mutation.

```swift
var array1 = [1, 2, 3, 4, 5]
var array2 = array1        // aucune copie mémoire pour l'instant : array2 partage le stockage d'array1

array2.append(6)             // la mutation déclenche la copie réelle, maintenant
print(array1)                  // [1, 2, 3, 4, 5] : inchangé
print(array2)                   // [1, 2, 3, 4, 5, 6]
```

Le résultat *observable* est exactement celui attendu de la value semantics (chaque variable se comporte comme si elle avait sa propre copie) — copy-on-write est uniquement une optimisation invisible de performance, détaillée plus en profondeur au chapitre 66.

### Comment choisir

| Utilisez... | Quand... |
|---|---|
| `struct` (par défaut) | La donnée représente une **valeur** : un nombre, une coordonnée, une configuration, un enregistrement immuable une fois créé. |
| `class` | Vous avez besoin d'une **identité partagée** : un gestionnaire d'état observé depuis plusieurs endroits, une ressource unique (connexion réseau, fichier ouvert), ou de l'héritage. |
| `enum` | Un ensemble **fini et fermé** de possibilités, avec ou sans données associées. |

La recommandation officielle de Swift, martelée dans toute la documentation Apple, est de **préférer `struct` par défaut**, et de ne passer à `class` que lorsqu'une raison précise l'exige (identité partagée ou héritage). Le Projet 4, juste après, met cette règle en pratique : un `Expense` individuel sera une `struct` (une valeur), tandis que le gestionnaire qui les collecte sera une `class` (une identité partagée, unique dans le programme).

<div class="exercise">
<div class="exercise-title">Exercice 25.1</div>
Sans écrire de code : pour chacun des cas suivants, décidez si vous utiliseriez une <code>struct</code> ou une <code>class</code>, et justifiez en une phrase. (a) Une coordonnée GPS. (b) Un gestionnaire de connexion à une base de données, unique dans l'application. (c) Une carte à jouer. (d) Le score d'une partie, partagé et mis à jour par plusieurs écrans différents de la même application.
</div>
