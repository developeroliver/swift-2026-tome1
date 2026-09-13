# Partie 2 — Les fondamentaux {#partie-2}

## 3. Variables et constantes {#chap-3}

### `let` et `var`

Swift a deux mots-clés pour déclarer une valeur nommée : `let` pour une **constante** (valeur immuable après son initialisation), et `var` pour une **variable** (valeur modifiable) :

```swift
let name = "Ada"        // constante : ne peut plus changer
var score = 0            // variable : peut être réassignée

score = 10                 // OK
score += 5                  // OK, score vaut maintenant 15
// name = "Grace"          // ERREUR DE COMPILATION : name est une constante
```

### Mutabilité : `let` par défaut

Contrairement à beaucoup de langages où `var`/variable mutable est le réflexe par défaut, l'usage idiomatique en Swift est **d'utiliser `let` systématiquement, et de ne passer à `var` que lorsque c'est nécessaire**. Cette discipline a un vrai intérêt :

- elle documente l'intention du code (« cette valeur ne changera jamais ») ;
- elle élimine par construction les bugs liés à une modification accidentelle ;
- elle permet au compilateur d'optimiser plus agressivement.

> **Piège courant** — Xcode et le compilateur vous avertiront (`warning`) si vous déclarez une `var` que vous ne modifiez jamais, en vous suggérant de la remplacer par `let`. Ne l'ignorez pas : c'est une bonne pratique, pas du bruit.

### Inférence de type

Swift déduit automatiquement le type d'une valeur à partir de ce qui lui est assigné — inutile de le préciser à chaque fois :

```swift
let number = 42            // Int, déduit automatiquement
let pi = 3.14159             // Double
let password = "azerty"       // String
let isActive = true             // Bool
```

### Annotation de type

Il est parfois nécessaire, ou plus clair, de préciser explicitement le type avec `: Type` :

```swift
let temperature: Double = 20    // sans l'annotation, Swift déduirait Int
var users: [String] = []         // tableau vide : Swift ne peut pas deviner le type du contenu
let id: Int
id = 42                             // annotation nécessaire ici car pas de valeur initiale
```

On annote le type dans trois cas fréquents : quand la valeur initiale ne suffit pas à déduire ce qu'on veut réellement (`20` serait un `Int` par défaut), quand une collection est vide, ou quand on déclare une constante sans l'initialiser immédiatement.

### Type safety

Swift est un langage à **typage statique et fort** : chaque valeur a un type déterminé à la compilation, et ce type ne change jamais implicitement. Contrairement à JavaScript ou Python, Swift ne convertit **jamais** silencieusement un type en un autre :

```swift
let age = 30
let text = "I am " + age + " years old"
// ERREUR DE COMPILATION :
// binary operator '+' cannot be applied to operands of type 'String' and 'Int'
```

Il faut convertir explicitement :

```swift
let text = "I am " + String(age) + " years old"
// ou, plus idiomatique :
let text2 = "I am \(age) years old"
```

Cette rigueur est précisément ce qui permet au compilateur de détecter énormément d'erreurs *avant* l'exécution — c'est un des piliers de la philosophie « safety » évoquée au chapitre 1.

<div class="exercise">
<div class="exercise-title">Exercice 3.1</div>
Déclarez une constante <code>username</code> (String) et une variable <code>loginCount</code> (Int) initialisée à 0. Incrémentez <code>loginCount</code> de 1 trois fois de suite, puis affichez une phrase récapitulative avec interpolation de chaîne.
</div>

## 4. Types fondamentaux {#chap-4}

### Les types entiers : `Int` et `UInt`

`Int` représente un entier signé (positif ou négatif), sur 64 bits sur toute plateforme moderne. C'est le type entier à utiliser **par défaut**, sauf raison précise :

```swift
let negativeTemperature: Int = -12
let population: Int = 8_000_000     // le _ est un séparateur visuel, ignoré par le compilateur
```

`UInt` représente un entier **non signé** (toujours positif ou nul). Son usage est rare en pratique — Apple recommande explicitement de préférer `Int` même pour des valeurs qui seront toujours positives, afin d'éviter les conversions incessantes entre types numériques :

```swift
let onlyPositive: UInt = 42
// let impossible: UInt = -1   // ERREUR DE COMPILATION
```

Swift propose aussi des tailles précises (`Int8`, `Int16`, `Int32`, `Int64`, et leurs équivalents `UInt*`), utiles en programmation bas niveau ou pour interagir avec des formats de données binaires.

### Les types flottants : `Double` et `Float`

`Double` (64 bits, ~15 chiffres significatifs) est le type **par défaut** pour tout nombre à virgule flottante en Swift :

```swift
let price: Double = 19.99
let interestRate = 0.045       // Double, par inférence
```

`Float` (32 bits, ~6 chiffres significatifs) offre une précision moindre pour un espace mémoire réduit — utile en contexte contraint (graphisme temps réel, embarqué), rarement nécessaire ailleurs :

```swift
let weight: Float = 72.5
```

> **Piège courant** — `Int` et `Double` ne se mélangent jamais implicitement dans une opération : `let x = 5 / 2.0` fonctionne (Swift déduit que `5` doit devenir un `Double`), mais `let n = 5; let x = n / 2.0` échoue à la compilation. Il faut convertir explicitement : `Double(n) / 2.0`.

### `Bool`

Le type booléen n'a que deux valeurs, `true` et `false` — et contrairement à C ou JavaScript, **aucune autre valeur ne peut être interprétée comme un booléen** : pas de `0`/`1`, pas de chaîne vide considérée comme fausse.

```swift
let isAdult = true
let hasFinished = false

if isAdult {
    print("Access granted")
}
```

### `String`

`String` représente du texte, toujours en Unicode complet. Les chaînes sont des **value types** (voir chapitre 25) : chaque copie est indépendante.

```swift
let greeting = "Hello"
let fullMessage = greeting + ", world!"     // concaténation avec +
var message = "Swift"
message += " is awesome"                       // += fonctionne aussi

let multiline = """
This is a string
on multiple lines,
with line breaks preserved.
"""

print(greeting.count)          // nombre de caractères : 5
print(greeting.uppercased())   // HELLO
print(greeting.isEmpty)         // false
```

L'interpolation (`\( )`, vue au chapitre 2) fonctionne avec n'importe quelle expression :

```swift
let a = 3, b = 4
print("\(a) + \(b) = \(a + b)")   // 3 + 4 = 7
```

### `Character`

Un `Character` représente un **seul caractère Unicode étendu (grapheme cluster)** — ce qui peut correspondre à plusieurs points de code Unicode assemblés (un emoji avec modificateur de couleur de peau, par exemple, reste un seul `Character`) :

```swift
let letter: Character = "A"
let flag: Character = "🇫🇷"        // un seul Character malgré la complexité Unicode sous-jacente

for character in "Swift" {
    print(character)                // affiche S, w, i, f, t chacun sur une ligne
}
```

Une `String` est en réalité une collection de `Character` — cette relation sera exploitée au chapitre 9 (Arrays) et lors du parcours de texte.

<div class="exercise">
<div class="exercise-title">Exercice 4.1</div>
Déclarez trois variables : un <code>Int</code> nommé <code>quantity</code>, un <code>Double</code> nommé <code>unitPrice</code>, et calculez le total (<code>Double</code>) en convertissant <code>quantity</code> avec <code>Double(...)</code>. Affichez le résultat avec deux décimales grâce à <code>String(format:)</code> ou une interpolation simple.
</div>

## 5. Opérateurs {#chap-5}

### Opérateurs arithmétiques

```swift
let sum = 5 + 3           // 8
let difference = 5 - 3     // 2
let product = 5 * 3          // 15
let quotient = 5 / 3           // 1 (division entière si les deux opérandes sont Int !)
let remainder = 5 % 3             // 2 (modulo)

let decimalQuotient = 5.0 / 3.0  // 1.6666...
```

> **Piège courant** — la division entre deux `Int` produit toujours un `Int`, tronqué (pas arrondi) : `5 / 3` vaut `1`, pas `1.67`. C'est une source d'erreur très fréquente chez les débutants venant d'autres langages.

### Opérateurs de comparaison

Ils renvoient toujours un `Bool` :

```swift
5 == 5     // true
5 != 3      // true
5 > 3        // true
5 >= 5        // true
5 < 3          // false
5 <= 3          // false
```

### Opérateurs logiques

```swift
let a = true
let b = false

a && b     // ET logique : false
a || b      // OU logique : true
!a           // NON logique : false
```

Swift utilise l'**évaluation court-circuit** : dans `a && b`, si `a` est `false`, `b` n'est jamais évalué (utile quand `b` a un effet de bord ou un coût de calcul).

### Opérateurs d'affectation composés

```swift
var x = 10
x += 5      // x = x + 5  → 15
x -= 3       // x = x - 3  → 12
x *= 2        // x = x * 2  → 24
x /= 4         // x = x / 4  → 6
```

> **Piège courant** — contrairement à C ou Java, Swift n'a **pas d'opérateurs d'incrémentation** `++` ou `--` (supprimés volontairement du langage). Il faut écrire `x += 1`.

### Opérateur ternaire

`condition ? valeurSiVrai : valeurSiFaux` — une forme condensée d'un `if`/`else` qui retourne une valeur :

```swift
let age = 20
let status = age >= 18 ? "adult" : "minor"
print(status)   // adult
```

À utiliser pour des choix simples ; au-delà de deux branches ou d'une logique complexe, un vrai `if`/`else` ou `switch` reste plus lisible.

### Opérateurs personnalisés

Swift permet de définir ses propres opérateurs, y compris de surcharger des opérateurs existants pour vos propres types (très utile avec les `struct`, voir chapitre 19) :

```swift
struct Vector2D {
    var x: Double
    var y: Double
}

func + (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
    Vector2D(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

let v1 = Vector2D(x: 1, y: 2)
let v2 = Vector2D(x: 3, y: 4)
let v3 = v1 + v2       // Vector2D(x: 4, y: 6)
```

Cette capacité est puissante mais à utiliser avec discernement : un opérateur personnalisé doit rester intuitif (`+` pour additionner deux vecteurs a du sens ; l'utiliser pour une opération sans rapport avec l'addition nuirait à la lisibilité).

<div class="exercise">
<div class="exercise-title">Exercice 5.1</div>
Écrivez une expression qui calcule la moyenne de trois notes (<code>Double</code>) et affiche, via l'opérateur ternaire, <code>"Pass"</code> si la moyenne est supérieure ou égale à 10, sinon <code>"Fail"</code>.
</div>

## 6. Conditions {#chap-6}

### `if`, `else`, `else if`

```swift
let temperature = 15

if temperature > 30 {
    print("It's hot")
} else if temperature > 15 {
    print("It's mild")
} else {
    print("It's cool")
}
```

En Swift, la condition d'un `if` doit être une expression `Bool` stricte — pas de parenthèses obligatoires autour de la condition, mais les accolades `{ }` sont **toujours obligatoires**, même pour une seule instruction :

```swift
// if temperature > 20 print("hot")   // ERREUR : les accolades sont requises
if temperature > 20 { print("hot") }   // OK
```

> **Piège courant** — venant de C, Java ou JavaScript, on a le réflexe d'écrire `if (condition)`. Ça compile en Swift (les parenthèses sont juste ignorées), mais ce n'est pas idiomatique : on écrit `if condition` sans parenthèses.

### `switch`

Le `switch` de Swift est bien plus puissant qu'en C ou Java : il n'y a **pas de fall-through implicite** (pas besoin de `break`), et il doit être **exhaustif** — chaque cas possible doit être couvert, au besoin avec `default` :

```swift
let day = "Wednesday"

switch day {
case "Saturday", "Sunday":
    print("Weekend")
case "Wednesday":
    print("Midweek")
default:
    print("Weekday")
}
```

### Pattern matching

Le `switch` peut matcher des intervalles, des tuples, et extraire des valeurs :

```swift
let grade = 14

switch grade {
case 0..<10:
    print("Fail")
case 10..<12:
    print("Pass")
case 12..<16:
    print("Good")
case 16...20:
    print("Excellent")
default:
    print("Invalid grade")
}
```

Matcher un tuple (coordonnées, par exemple) :

```swift
let point = (0, 0)

switch point {
case (0, 0):
    print("Origin")
case (_, 0):
    print("On the X axis")
case (0, _):
    print("On the Y axis")
default:
    print("Somewhere else: \(point)")
}
```

### La clause `where`

`where` ajoute une condition supplémentaire à un `case`, pour un filtrage fin :

```swift
let point2 = (3, 3)

switch point2 {
case let (x, y) where x == y:
    print("On the diagonal")
case let (x, y):
    print("Some point: (\(x), \(y))")
}
```

`where` reviendra dans plusieurs autres contextes du livre : les boucles `for-in` (chapitre 7), les generics (chapitre 36), les protocoles avec `associatedtype` (chapitre 33).

<div class="exercise">
<div class="exercise-title">Exercice 6.1</div>
Écrivez un <code>switch</code> qui prend un <code>Int</code> représentant un mois (1 à 12) et affiche la saison correspondante (<code>"Winter"</code>, <code>"Spring"</code>, <code>"Summer"</code>, <code>"Fall"</code>) en utilisant des intervalles (<code>case 3...5:</code>, etc.).
</div>

## 7. Boucles {#chap-7}

### `for-in`

La boucle la plus utilisée en Swift : elle parcourt une séquence (intervalle, tableau, dictionnaire...) :

```swift
for i in 1...5 {
    print(i)                 // 1, 2, 3, 4, 5
}

let fruits = ["apple", "banana", "cherry"]
for fruit in fruits {
    print(fruit)
}

for (index, fruit) in fruits.enumerated() {
    print("\(index): \(fruit)")   // 0: apple, 1: banana, 2: cherry
}
```

Si vous n'avez pas besoin de la valeur de la boucle, la convention est d'utiliser `_` :

```swift
var counter = 0
for _ in 1...10 {
    counter += 1
}
```

### `while`

Exécute le bloc tant que la condition reste vraie, testée **avant** chaque itération :

```swift
var energy = 100
while energy > 0 {
    energy -= 25
    print("Energy remaining: \(energy)")
}
```

### `repeat-while`

Équivalent du `do-while` d'autres langages : le bloc s'exécute **au moins une fois**, la condition étant testée **après** :

```swift
var attempt = 0
repeat {
    attempt += 1
    print("Attempt \(attempt)")
} while attempt < 3
```

À utiliser quand on sait que le bloc doit s'exécuter au moins une fois avant même de tester la condition (une saisie utilisateur à valider, par exemple — voir le Projet 1).

### `break` et `continue`

`break` interrompt immédiatement la boucle ; `continue` passe directement à l'itération suivante :

```swift
for i in 1...10 {
    if i == 7 {
        break                 // arrête la boucle dès que i vaut 7
    }
    print(i)                  // affiche 1 à 6
}

for i in 1...10 {
    if i % 2 == 0 {
        continue               // ignore les nombres pairs
    }
    print(i)                   // affiche 1, 3, 5, 7, 9
}
```

`for-in` accepte aussi un `where` pour filtrer directement dans l'en-tête de boucle, souvent plus lisible qu'un `continue` :

```swift
for i in 1...10 where i % 2 != 0 {
    print(i)     // équivalent au continue ci-dessus, mais plus direct
}
```

<div class="exercise">
<div class="exercise-title">Exercice 7.1</div>
Écrivez une boucle <code>while</code> qui simule un compte à rebours de 10 à 1, affiche chaque nombre, puis affiche <code>"Liftoff!"</code> à la fin. Réécrivez ensuite la même logique avec <code>for-in</code> sur un intervalle décroissant (indice : <code>stride(from:through:by:)</code>).
</div>

## 8. Ranges {#chap-8}

### `...` (intervalle fermé)

`a...b` représente tous les nombres de `a` à `b`, **bornes incluses** :

```swift
for i in 1...5 {
    print(i)     // 1, 2, 3, 4, 5
}
```

### `..<` (intervalle semi-ouvert)

`a..<b` inclut `a` mais **exclut** `b` — extrêmement utile pour parcourir des indices de collection (voir chapitre 9), où l'on veut typiquement aller de `0` jusqu'à `count` exclu :

```swift
let letters = ["a", "b", "c", "d"]
for i in 0..<letters.count {
    print(letters[i])
}
```

### Ranges avec collections

Les ranges permettent d'extraire une sous-partie d'une collection via le *subscript* :

```swift
let numbers = [10, 20, 30, 40, 50]
print(numbers[1...3])      // [20, 30, 40]
print(numbers[..<2])        // [10, 20] : depuis le début jusqu'à l'indice 2 exclu
print(numbers[2...])         // [30, 40, 50] : de l'indice 2 jusqu'à la fin
```

> **Piège courant** — un `Range` construit avec des bornes invalides (`5..<2`, où la borne de fin est inférieure à celle de début) provoque un **crash à l'exécution**, pas une erreur de compilation. Vérifiez toujours que votre borne de fin est supérieure ou égale à votre borne de début, surtout si elles proviennent de calculs.

Il existe aussi `stride(from:to:by:)` et `stride(from:through:by:)` pour des intervalles avec un pas différent de 1 :

```swift
for i in stride(from: 0, to: 10, by: 2) {
    print(i)          // 0, 2, 4, 6, 8
}

for i in stride(from: 10, through: 0, by: -2) {
    print(i)          // 10, 8, 6, 4, 2, 0
}
```

<div class="exercise">
<div class="exercise-title">Exercice 8.1</div>
Étant donné <code>let words = ["one", "two", "three", "four", "five"]</code>, affichez uniquement les trois premiers éléments en utilisant un range, puis affichez uniquement les éléments d'indice pair en utilisant <code>stride</code>.
</div>
