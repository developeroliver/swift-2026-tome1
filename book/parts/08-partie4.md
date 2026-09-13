# Partie 4 — Fonctions {#partie-4}

## 13. Fonctions {#chap-13}

### Déclaration

Une fonction se déclare avec `func`, un nom, des paramètres entre parenthèses, et optionnellement un type de retour introduit par `->` :

```swift
func greet() {
    print("Hello!")
}

greet()   // Hello!
```

### Paramètres et retour

```swift
func square(_ number: Int) -> Int {
    return number * number
}

print(square(5))   // 25
```

Depuis Swift 5.1, si le corps de la fonction ne contient qu'une seule expression, le `return` est implicite :

```swift
func cube(_ number: Int) -> Int {
    number * number * number       // pas besoin de "return"
}
```

### Plusieurs paramètres

```swift
func add(_ a: Int, _ b: Int) -> Int {
    a + b
}

print(add(3, 4))   // 7
```

### Paramètres externes et internes

C'est une des particularités les plus distinctives de Swift : chaque paramètre peut avoir **deux noms** — un nom **externe**, utilisé à l'appel de la fonction, et un nom **interne**, utilisé dans son corps. Par défaut, les deux sont identiques :

```swift
func greet(person: String) {
    print("Hello, \(person)!")
}
greet(person: "Ada")     // le nom externe "person" est obligatoire à l'appel
```

On peut donner un nom externe différent, souvent pour rendre l'appel plus proche d'une phrase en anglais :

```swift
func greet(warmly person: String) {
    print("Hello, \(person)!")     // "warmly" n'existe pas ici, seulement "person"
}
greet(warmly: "Ada")     // Hello, Ada!
```

### Le underscore `_`

Faire précéder un paramètre de `_` supprime l'obligation de nommer l'argument à l'appel — très utilisé quand le nom du paramètre n'apporte rien à la lisibilité (comme `square(_ number: Int)` plus haut) :

```swift
func multiply(_ a: Int, by b: Int) -> Int {
    a * b
}
print(multiply(6, by: 7))   // 42 : le premier argument n'est pas nommé, le second l'est
```

Ce mélange (premier paramètre sans nom, suivants nommés) est un idiome extrêmement courant en Swift, visible dans toute l'API standard (`array.contains(_:)`, `string.replacingOccurrences(of:with:)`...).

### Valeurs par défaut

Un paramètre peut avoir une valeur par défaut, rendant son omission possible à l'appel :

```swift
func greet(_ name: String, warmly: Bool = false) {
    print(warmly ? "Hello dear \(name)!" : "Hello, \(name).")
}

greet("Ada")                    // Hello, Ada.
greet("Ada", warmly: true)        // Hello dear Ada!
```

<div class="exercise">
<div class="exercise-title">Exercice 13.1</div>
Écrivez une fonction <code>isEven(_ number: Int) -> Bool</code> qui renvoie <code>true</code> si le nombre est pair. Puis écrivez <code>describe(_ number: Int, unit: String = "item") -> String</code> qui renvoie par exemple <code>"3 items"</code> ou, avec <code>unit: "point"</code>, <code>"3 points"</code>.
</div>

## 14. Fonctions avancées {#chap-14}

### Les fonctions sont des valeurs

En Swift, une fonction a un type (comme `(Int, Int) -> Int`) et peut être manipulée comme n'importe quelle autre valeur : stockée dans une constante, passée en paramètre, retournée par une autre fonction.

```swift
func add(_ a: Int, _ b: Int) -> Int { a + b }
func subtract(_ a: Int, _ b: Int) -> Int { a - b }

var operation: (Int, Int) -> Int = add
print(operation(5, 3))   // 8

operation = subtract
print(operation(5, 3))   // 2
```

### Fonctions en paramètre (higher-order functions)

Une fonction qui prend une autre fonction en paramètre, ou qui en renvoie une, est appelée **higher-order function**. Vous en utilisez déjà depuis le chapitre 9 : `map`, `filter` et `reduce` en sont les exemples les plus courants.

```swift
func applyTwice(_ operation: (Int) -> Int, to value: Int) -> Int {
    operation(operation(value))
}

func increment(_ n: Int) -> Int { n + 1 }

print(applyTwice(increment, to: 10))   // 12
```

### Fonctions qui renvoient des fonctions

```swift
func makeMultiplier(by factor: Int) -> (Int) -> Int {
    func multiplier(_ value: Int) -> Int {
        value * factor
    }
    return multiplier
}

let triple = makeMultiplier(by: 3)
print(triple(7))   // 21
```

`makeMultiplier` construit et renvoie une fonction spécialisée, qui « se souvient » de `factor` — un aperçu du mécanisme de capture détaillé avec les closures juste après.

### `inout`

Par défaut, les paramètres d'une fonction sont des **copies** : les modifier à l'intérieur de la fonction n'affecte pas la variable d'origine à l'extérieur. Le mot-clé `inout` change ce comportement en permettant à la fonction de modifier directement la variable passée en argument :

```swift
func double(_ value: inout Int) {
    value *= 2
}

var number = 21
double(&number)          // le & est obligatoire à l'appel, pour signaler la mutation
print(number)              // 42
```

> **Piège courant** — `inout` exige une **variable** (`var`), jamais une constante (`let`) ni une valeur littérale : `double(&someConstant)` ou `double(&5)` ne compilent pas. Le `&` à l'appel n'est pas optionnel — c'est un rappel visuel intentionnel que la fonction va modifier cet argument.

### Paramètres variadiques

Un paramètre variadique accepte un nombre variable d'arguments, rassemblés automatiquement dans un `Array` à l'intérieur de la fonction :

```swift
func sum(_ numbers: Int...) -> Int {
    numbers.reduce(0, +)
}

print(sum(1, 2, 3))          // 6
print(sum(1, 2, 3, 4, 5))     // 15
print(sum())                    // 0
```

<div class="exercise">
<div class="exercise-title">Exercice 14.1</div>
Écrivez une fonction <code>average(_ numbers: Double...) -> Double</code> qui calcule la moyenne d'un nombre variable de valeurs (attention à la division par zéro si aucun argument n'est fourni). Puis écrivez une fonction <code>incrementInPlace(_ value: inout Int, by amount: Int = 1)</code> qui augmente <code>value</code> directement.
</div>

## 15. Closures {#chap-15}

### Syntaxe

Une closure est une fonction **sans nom**, qui peut être définie à l'endroit où on l'utilise. Sa syntaxe complète :

```swift
let square: (Int) -> Int = { (number: Int) -> Int in
    return number * number
}
print(square(6))   // 36
```

Le mot-clé `in` sépare la signature (paramètres et type de retour) du corps de la closure.

### Simplifications progressives

Swift permet d'omettre progressivement tout ce que le compilateur peut déduire par inférence de type :

```swift
let numbers = [1, 2, 3, 4, 5]

// Forme complète
let doubled1 = numbers.map({ (n: Int) -> Int in n * 2 })

// Types inférés (map connaît déjà le type des éléments de "numbers")
let doubled2 = numbers.map({ n in n * 2 })

// Argument raccourci $0
let doubled3 = numbers.map({ $0 * 2 })

// Trailing closure : la closure sort des parenthèses
let doubled4 = numbers.map { $0 * 2 }
```

Ces quatre lignes sont strictement équivalentes. La dernière forme, dite **trailing closure**, est de très loin la plus utilisée en Swift idiomatique dès que la closure est le dernier (ou seul) argument de la fonction.

### Trailing closures avec plusieurs arguments

Depuis Swift 5.3, une fonction peut accepter **plusieurs** trailing closures, chacune nommée sauf la première :

```swift
func fetchData(onSuccess: () -> Void, onFailure: () -> Void) {
    onSuccess()   // simplifié pour l'exemple
}

fetchData {
    print("Success!")
} onFailure: {
    print("Failure!")
}
```

### Capture de variables

Une closure **capture** les variables de son contexte environnant, et peut continuer à les utiliser (et même les modifier) après que ce contexte a disparu :

```swift
func makeCounter() -> () -> Int {
    var count = 0
    return {
        count += 1
        return count
    }
}

let counter = makeCounter()
print(counter())   // 1
print(counter())   // 2
print(counter())   // 3
```

Chaque appel à `makeCounter()` crée une **nouvelle** variable `count`, capturée par sa propre closure — deux compteurs créés séparément sont totalement indépendants.

### `@escaping`

Une closure passée en paramètre est dite **escaping** si elle est stockée pour être appelée **après** que la fonction soit terminée (typiquement, un callback réseau exécuté plus tard). Swift exige de le déclarer explicitement avec `@escaping`, car cela change la façon dont la mémoire de la closure doit être gérée (voir Partie 12) :

```swift
var savedCompletion: (() -> Void)?

func performLater(_ completion: @escaping () -> Void) {
    savedCompletion = completion    // la closure "s'échappe" de la fonction : elle vivra plus longtemps qu'elle
}

performLater {
    print("Executed later")
}
savedCompletion?()   // Executed later
```

> **Piège courant** — oublier `@escaping` quand c'est nécessaire produit une **erreur de compilation** claire (« escaping closure captures non-escaping parameter »), pas un bug silencieux : le compilateur refuse de stocker une closure non-escaping au-delà de la durée de vie de la fonction. C'est un garde-fou, pas une contrainte arbitraire.

### Closures autocontenues (IIFE)

Une closure peut être définie et immédiatement exécutée, utile pour isoler un calcul complexe dans une constante sans polluer l'espace environnant avec des variables temporaires :

```swift
let discountedPrice: Double = {
    let basePrice = 100.0
    let discount = 0.2
    return basePrice * (1 - discount)
}()

print(discountedPrice)   // 80.0
```

Seul `discountedPrice` existe en dehors de la closure — `basePrice` et `discount` restent des détails d'implémentation invisibles à l'extérieur.

<div class="exercise">
<div class="exercise-title">Exercice 15.1</div>
Étant donné <code>let words = ["swift", "is", "great"]</code>, utilisez <code>sorted(by:)</code> avec une closure en trailing syntax pour trier le tableau par longueur de mot croissante. Puis écrivez une fonction <code>makeGreeter(prefix: String) -> (String) -> String</code> qui renvoie une closure ajoutant le préfixe au nom qu'on lui passe (par exemple <code>makeGreeter(prefix: "Hello, ")("Ada")</code> doit renvoyer <code>"Hello, Ada"</code>).
</div>
