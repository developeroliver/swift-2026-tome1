# Partie 13 — Swift avancé {#partie-13}

## 42. Access Control {#chap-42}

### Les niveaux, du plus restrictif au plus ouvert

Swift propose six niveaux de contrôle d'accès, qui déterminent depuis où une déclaration (property, méthode, type...) est utilisable :

```swift
private       // seulement dans la déclaration englobante elle-même (et ses extensions dans le même fichier)
fileprivate   // seulement dans le fichier source actuel
internal      // partout dans le module actuel (le niveau par défaut, si rien n'est précisé)
public        // depuis n'importe quel module, mais pas redéfinissable/héritable depuis l'extérieur
open          // comme public, mais aussi héritable et redéfinissable depuis un autre module
package       // partout dans le même package Swift (plusieurs modules), pas au-delà
```

```swift
struct BankAccount {
    private var balance: Double = 0     // inaccessible même à un autre type du même fichier

    mutating func deposit(_ amount: Double) {
        balance += amount                  // OK : à l'intérieur du type qui déclare balance
    }

    func currentBalance() -> Double {
        balance
    }
}

var account = BankAccount()
account.deposit(100)
print(account.currentBalance())    // 100.0
// print(account.balance)          // ERREUR : balance est private
```

### Pourquoi restreindre l'accès

Restreindre l'accès n'est pas une contrainte bureaucratique : c'est ce qui permet de garantir des **invariants**. Ici, `balance` ne peut être modifié que via `deposit(_:)`, qui pourrait ajouter une validation (refuser un montant négatif, par exemple) — impossible à contourner en modifiant `balance` directement, puisque personne d'autre que `BankAccount` lui-même n'y a accès.

### `internal` par défaut

Si aucun modificateur n'est écrit, une déclaration est `internal` — visible partout dans le module actuel (votre application, ou votre package Swift, chapitre 60), mais invisible depuis un autre module qui l'importerait. C'est un choix par défaut réfléchi : suffisamment ouvert pour un usage quotidien au sein d'un même projet, mais qui ne fuite rien vers l'extérieur sans décision explicite.

### `public` vs `open`

La différence entre les deux ne compte que pour les `class` : une classe `public` peut être **utilisée** depuis un autre module, mais pas sous-classée ; une classe `open` peut aussi être **héritée et redéfinie** depuis l'extérieur. C'est un choix de conception délibéré pour l'auteur d'une bibliothèque : `open` est un engagement explicite que la classe est conçue pour être étendue par ses utilisateurs.

<div class="exercise">
<div class="exercise-title">Exercice 42.1</div>
Reprenez la <code>struct BankAccount</code> ci-dessus et ajoutez une méthode <code>private func logTransaction(_ amount: Double)</code>, appelée depuis <code>deposit(_:)</code>. Vérifiez qu'elle est bien inaccessible depuis l'extérieur du type.
</div>

## 43. Type Casting {#chap-43}

### `is`

`is` teste si une valeur est d'un type donné, et renvoie un simple `Bool` :

```swift
class Animal {}
class Dog: Animal {}
class Cat: Animal {}

let animals: [Animal] = [Dog(), Cat(), Dog()]

for animal in animals {
    if animal is Dog {
        print("It's a dog")
    }
}
```

### `as` (upcast, toujours sûr)

`as` convertit vers un type **parent** (ou un protocole que le type respecte) — cette direction est toujours sûre, puisqu'une sous-classe possède forcément tout ce que sa superclasse promet :

```swift
let dog = Dog()
let animal = dog as Animal    // toujours valide, aucun risque d'échec
```

### `as?` (downcast conditionnel)

`as?` tente une conversion vers un type **plus précis** (une sous-classe, ou un type concret depuis un protocole) — direction qui peut échouer, d'où l'Optionnel en retour, déjà rencontré au chapitre 17 :

```swift
for animal in animals {
    if let dog = animal as? Dog {
        print("Found a dog: \(dog)")
    } else if let cat = animal as? Cat {
        print("Found a cat: \(cat)")
    }
}
```

### `as!` (downcast forcé)

`as!` effectue la même conversion que `as?`, mais extrait directement la valeur — avec le même risque que le force unwrap (chapitre 17) et `try!` (chapitre 38) : un **crash immédiat** si la conversion échoue :

```swift
let firstAnimal = animals[0]
let definitelyADog = firstAnimal as! Dog   // crash si animals[0] n'est pas un Dog
```

> **Piège courant** — comme pour `!` et `try!`, `as!` ne devrait apparaître dans du code de production que lorsque le type réel est garanti par une invariant du programme lui-même (par exemple, une API qui documente qu'elle ne renvoie jamais que des `Dog` dans ce tableau précis) — jamais comme raccourci de commodité face à un `as?` qu'on ne veut pas gérer proprement.

<div class="exercise">
<div class="exercise-title">Exercice 43.1</div>
Créez une classe <code>Shape</code> et deux sous-classes <code>Circle</code> et <code>Square</code>. Dans un tableau <code>[Shape]</code> mélangeant les deux, utilisez <code>as?</code> dans une boucle pour compter combien d'éléments sont des <code>Circle</code>.
</div>

## 44. Opaque Types {#chap-44}

### Le problème que `some` résout

Rappelez-vous le chapitre 33 : un protocole avec `associatedtype` ne peut pas être utilisé directement comme type de retour d'une fonction :

```swift
protocol Shape {
    func area() -> Double
}

struct Circle: Shape {
    var radius: Double
    func area() -> Double { .pi * radius * radius }
}
```

Ici `Shape` n'a pas d'`associatedtype` — le retourner directement serait déjà possible avec `any` (chapitre suivant). Mais Swift propose une alternative, `some`, qui a un avantage de performance et de clarté même dans ce cas simple :

```swift
func makeShape() -> some Shape {
    Circle(radius: 5)
}
```

### `some` : « un type concret précis, mais caché »

`some Shape` signifie : « cette fonction renvoie **un type concret spécifique et fixe** qui respecte `Shape` — mais je ne vous dis pas lequel ». Contrairement à `any` (chapitre 45), le compilateur **connaît** le type exact à la compilation (ici, `Circle`) ; il choisit simplement de ne pas l'exposer dans la signature publique. Cela permet à l'appelant d'utiliser des opérations qui exigent un type concret fixe (comme `==` avec `Equatable`), tout en gardant la liberté, pour l'auteur de la fonction, de changer l'implémentation interne sans casser la signature publique :

```swift
let shape = makeShape()
print(shape.area())   // 78.53...
```

### Pourquoi `some` existe

Sans `some`, il faudrait soit exposer le type concret exact (`func makeShape() -> Circle`, ce qui expose un détail d'implémentation qu'on voudrait pouvoir changer librement), soit utiliser `any Shape` (chapitre 45), qui a un coût de performance et perd certaines garanties de type — en particulier, deux `any Shape` ne peuvent pas être comparés avec `==` même si le type concret sous-jacent est `Equatable`, alors que deux `some Shape` identiques le peuvent, puisque le compilateur connaît le vrai type. `some` est le choix par défaut recommandé dès que le type de retour est fixe et connu à la compilation.

> **Anticipation** — vous croiserez `some View` à chaque fonction du Tome 2 (SwiftUI) : c'est exactement ce même mécanisme, appliqué aux vues d'interface graphique.

<div class="exercise">
<div class="exercise-title">Exercice 44.1</div>
Ajoutez une seconde struct <code>Square: Shape</code>. Écrivez une fonction <code>func makeDefaultShape() -> some Shape</code> qui renvoie toujours un <code>Circle</code> de rayon 1. Pourquoi cette même fonction ne pourrait-elle pas renvoyer tantôt un <code>Circle</code>, tantôt un <code>Square</code>, selon une condition ? (Indice : relisez la définition de <code>some</code> ci-dessus.)
</div>

## 45. Existentials {#chap-45}

### `any`

`any Protocole` désigne « n'importe quel type, quel qu'il soit, du moment qu'il respecte ce protocole » — le type concret n'est pas fixé à la compilation, et peut même varier d'un appel à l'autre :

```swift
protocol Shape {
    func area() -> Double
}
struct Circle: Shape {
    var radius: Double
    func area() -> Double { .pi * radius * radius }
}
struct Square: Shape {
    var side: Double
    func area() -> Double { side * side }
}

func randomShape(favorCircle: Bool) -> any Shape {
    favorCircle ? Circle(radius: 3) : Square(side: 4)   // types concrets différents, tous deux acceptés
}
```

Ceci ne compilerait **pas** avec `some Shape` — la contrainte de `some` (un seul type concret fixe pour toutes les exécutions de la fonction) est justement ce que cet exemple viole délibérément.

### Protocol existentials au quotidien

Vous utilisez des existentials depuis le début du livre sans le savoir : chaque fois qu'une variable ou un paramètre a pour type un protocole utilisé directement (`Greetable`, chapitre 30 ; `Error`, chapitre 37), c'est un existential — Swift a longtemps permis cette syntaxe sans exiger le mot-clé `any` explicite, mais les versions récentes du langage encouragent (et à terme, exigent) de l'écrire pour plus de clarté :

```swift
let items: [any Shape] = [Circle(radius: 1), Square(side: 2)]
for item in items {
    print(item.area())
}
```

### `some` vs `any`

| | `some Protocole` | `any Protocole` |
|---|---|---|
| Type concret | Fixe, connu du compilateur, cohérent à chaque appel | Variable, peut différer à chaque valeur |
| Performance | Optimale (résolution statique) | Léger surcoût (indirection à l'exécution) |
| Peut mélanger plusieurs types conformes ? | Non | Oui (ex : `[any Shape]` contenant des `Circle` et des `Square`) |
| Recommandation | Par défaut, dès que le type est fixe | Quand une hétérogénéité réelle est nécessaire |

<div class="exercise">
<div class="exercise-title">Exercice 45.1</div>
Créez un tableau <code>[any Shape]</code> mélangeant plusieurs <code>Circle</code> et <code>Square</code>, et calculez la somme totale de leurs aires avec <code>reduce</code> (chapitre 9).
</div>

## 46. Metatypes {#chap-46}

### `Type`

Chaque type Swift a lui-même un type — son *metatype*, noté `Type`. `SomeType.self` donne accès à cette valeur représentant le type lui-même, distincte de toute instance de ce type :

```swift
struct User {}

let userType: User.Type = User.self
print(userType)   // User
```

C'est utile pour comparer des types entre eux, ou pour choisir dynamiquement un type à instancier :

```swift
func makeInstance<T>(of type: T.Type) -> T? where T: DefaultConstructible {
    type.init()
}

protocol DefaultConstructible {
    init()
}
struct Empty: DefaultConstructible {}

let instance = makeInstance(of: Empty.self)
```

### `self` vs `Self`

`self` (minuscule) désigne **l'instance courante** — vous l'utilisez depuis le chapitre 19. `Self` (majuscule) désigne **le type courant**, particulièrement utile dans un protocole ou une classe destinée à être héritée, où le type exact n'est connu qu'à l'exécution pour chaque sous-type :

```swift
protocol Copyable {
    func copy() -> Self
}

class Document: Copyable {
    var title: String
    init(title: String) { self.title = title }

    func copy() -> Self {
        type(of: self).init(title: title)
    }

    required init(title: String) {
        self.title = title
    }
}
```

Dans une méthode `static`, `Self` désigne le type sur lequel la méthode est appelée — utile dans une hiérarchie de classes pour qu'une méthode de la classe parente continue de fonctionner correctement pour n'importe laquelle de ses sous-classes :

```swift
class Animal {
    static func create() -> Self {
        Self.init()
    }
    required init() {}
}
```

<div class="exercise">
<div class="exercise-title">Exercice 46.1</div>
Écrivez une fonction générique <code>typeName&lt;T&gt;(of value: T) -> String</code> qui renvoie le nom du type de <code>value</code> sous forme de chaîne (indice : <code>String(describing: type(of: value))</code>). Testez-la avec un <code>Int</code>, une <code>String</code> et une instance personnalisée.
</div>

## 47. Key Paths {#chap-47}

### `\Type.property`

Un *key path* représente une **référence non appelée** vers une property — pas sa valeur, mais le chemin pour y accéder, qu'on peut stocker, passer en paramètre, et appliquer plus tard à n'importe quelle instance du type :

```swift
struct User {
    let name: String
    let age: Int
}

let nameKeyPath = \User.name

let user = User(name: "Ada", age: 36)
print(user[keyPath: nameKeyPath])   // Ada
```

### Pourquoi c'est utile : passer une property comme une fonction

Là où une closure (`{ $0.name }`) fait à peu près la même chose, un key path est une donnée à part entière — comparable, stockable, et surtout directement acceptée par de nombreuses méthodes de la bibliothèque standard, dont `map` :

```swift
let users = [User(name: "Ada", age: 36), User(name: "Grace", age: 85)]
let names = users.map(\.name)          // ["Ada", "Grace"] : équivalent à users.map { $0.name }
```

### `WritableKeyPath`

Si la property référencée est modifiable (`var`, pas `let`), le key path devient un `WritableKeyPath`, utilisable pour **assigner** une nouvelle valeur, pas seulement la lire :

```swift
struct MutableUser {
    var name: String
    var age: Int
}

var user2 = MutableUser(name: "Ada", age: 36)
let ageKeyPath: WritableKeyPath<MutableUser, Int> = \.age
user2[keyPath: ageKeyPath] = 37
print(user2.age)   // 37
```

### `PartialKeyPath`

`PartialKeyPath<Root>` représente un key path dont on ne connaît que le type de départ (`Root`), pas le type de la valeur pointée — utile pour manipuler une collection hétérogène de key paths d'un même type :

```swift
let keyPaths: [PartialKeyPath<User>] = [\User.name, \User.age]

for kp in keyPaths {
    print(user[keyPath: kp])   // fonctionne, mais le type précis de chaque valeur n'est plus connu statiquement
}
```

Les key paths seront omniprésents au Tome 2 : les bindings SwiftUI (`$model.propertyName`) reposent directement sur ce mécanisme.

<div class="exercise">
<div class="exercise-title">Exercice 47.1</div>
Étant donné <code>struct Product { let name: String; let price: Double }</code> et un tableau de plusieurs <code>Product</code>, utilisez <code>.map(\.price)</code> puis <code>reduce</code> pour calculer le prix total, sans écrire une seule closure explicite pour l'étape du <code>map</code>.
</div>
