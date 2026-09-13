# Partie 5 — Optionnels {#partie-5}

## 16. Comprendre les Optionnels {#chap-16}

### Pourquoi `Optional` ?

Dans beaucoup de langages, une variable « vide » se représente par `null`, `nil`, `None`, ou `undefined` — et n'importe quelle variable de n'importe quel type peut potentiellement contenir cette valeur spéciale, ce qui oblige à s'en méfier **partout**, tout le temps. C'est la source de bugs la plus commune en programmation, au point que son inventeur, Tony Hoare, l'a lui-même qualifiée d'« erreur à un milliard de dollars ».

Swift prend le problème à revers : **une valeur normale ne peut jamais être absente**. Si vous déclarez `let age: Int`, cette variable contient *forcément* un entier — jamais autre chose, jamais « rien ». Pour représenter une valeur qui peut légitimement être absente, il faut le déclarer **explicitement** dans le type, avec `Optional`.

### `nil`

`nil` représente l'absence de valeur. Contrairement à beaucoup de langages, `nil` n'est pas une valeur universelle : il ne peut être assigné qu'à une variable dont le type est explicitement **optionnel**.

```swift
var name: String = "Ada"
// name = nil        // ERREUR DE COMPILATION : String n'est pas optionnel

var middleName: String? = "Grace"
middleName = nil        // OK : String? (String optionnel) peut être nil
```

### `String?` et `Int?`

Le suffixe `?` après un type transforme n'importe quel type en sa version optionnelle : `String?` signifie « soit une `String`, soit rien (`nil`) ». C'est en réalité un raccourci de syntaxe pour un véritable type Swift, `Optional<String>` — un enum standard de la bibliothèque, avec exactement deux cas :

```swift
enum Optional<Wrapped> {
    case none          // équivalent de nil
    case some(Wrapped)  // contient une valeur
}
```

Comprendre qu'un Optionnel *est* un enum (voir chapitre 20) démystifie complètement le mécanisme : `Int?` n'est pas de la magie du compilateur, c'est juste `Optional<Int>`, dont on peut afficher les deux cas :

```swift
let a: Int? = 42
let b: Int? = nil

print(a)   // Optional(42)
print(b)   // nil
```

> **Piège courant** — afficher directement un Optionnel avec `print()` fait apparaître `Optional(42)` plutôt que `42`, ce qui surprend au début. Ce n'est pas un bug : Swift vous rappelle explicitement que la valeur est « emballée » dans un Optionnel, et que vous ne l'avez pas encore extraite. Le chapitre suivant montre comment le faire proprement.

Un Optionnel se comporte comme n'importe quel autre type : on peut avoir un tableau d'optionnels (`[Int?]`), un optionnel de tableau (`[Int]?`), un optionnel de dictionnaire, etc. — chacun avec une signification différente, détaillée au chapitre 18.

<div class="exercise">
<div class="exercise-title">Exercice 16.1</div>
Déclarez une variable <code>middleName: String?</code> sans lui donner de valeur initiale (elle vaudra <code>nil</code> par défaut). Affichez-la avec <code>print()</code> et observez le résultat. Donnez-lui ensuite une valeur et affichez-la à nouveau.
</div>

## 17. Manipuler les Optionnels {#chap-17}

### `if let`

`if let` extrait la valeur d'un Optionnel **si elle existe**, et l'expose comme une constante normale (non optionnelle) dans le bloc `if` :

```swift
let input: String? = "42"

if let number = Int(input!) {   // voir plus bas pour le "!" — à éviter en pratique
    print("Valid number: \(number)")
} else {
    print("Not a number")
}
```

Depuis Swift 5.7, on peut aussi utiliser la forme raccourcie quand le nom de la nouvelle constante est identique à celui de l'Optionnel d'origine :

```swift
var username: String? = "ada"

if let username {
    print("Hello, \(username)")   // username est ici un String, non optionnel
} else {
    print("No username")
}
```

### `guard let`

`guard let` est le miroir de `if let` : au lieu d'exécuter un bloc **si** la valeur existe, il **exige** que la valeur existe pour continuer, et quitte immédiatement (`return`, `break`, `continue`) sinon. Vous l'avez déjà utilisé dans les Projets 1 à 3 :

```swift
func greet(_ name: String?) {
    guard let name else {
        print("No name provided")
        return
    }
    print("Hello, \(name)!")   // name est non optionnel à partir d'ici
}
```

La différence de fond entre les deux : `if let` crée une valeur non optionnelle valable **seulement à l'intérieur du bloc** ; `guard let` crée une valeur non optionnelle valable **pour tout le reste de la fonction**, ce qui évite d'imbriquer du code dans des `if` en cascade. C'est pour cette raison que `guard let` est généralement préféré pour les vérifications en début de fonction.

### Optional chaining

Le `?` permet d'accéder en toute sécurité à une propriété ou une méthode d'un Optionnel : si la valeur est `nil` à n'importe quelle étape de la chaîne, l'expression entière renvoie `nil` immédiatement, sans crash :

```swift
struct Address {
    let city: String
}
struct Person {
    let address: Address?
}

let person = Person(address: nil)
let city = person.address?.city         // nil, sans crash
print(city ?? "Unknown city")             // Unknown city
```

Le résultat d'un optional chaining est **toujours un Optionnel**, même si la propriété finale ne l'était pas : ici, `city` est de type `String?`, pas `String`, précisément parce que `person.address` pouvait être `nil`.

### `??` (nil-coalescing)

L'opérateur `??` fournit une valeur par défaut quand l'Optionnel de gauche est `nil` :

```swift
let savedName: String? = nil
let displayName = savedName ?? "Guest"
print(displayName)   // Guest
```

`??` se chaîne naturellement :

```swift
let first: String? = nil
let second: String? = nil
let third = "Fallback"
print(first ?? second ?? third)   // Fallback
```

### `!` (force unwrap)

Le point d'exclamation extrait la valeur d'un Optionnel **sans vérification** : si la valeur est `nil`, le programme **plante immédiatement**.

```swift
let value: Int? = 42
print(value!)   // 42

let empty: Int? = nil
// print(empty!)   // CRASH à l'exécution : "Fatal error: Unexpectedly found nil"
```

> **Piège courant** — le force unwrap est la source de crash la plus fréquente chez les débutants Swift, précisément parce qu'il *compile* toujours, même quand il est dangereux. N'utilisez `!` que lorsque vous êtes absolument certain, par construction du programme, que la valeur ne peut pas être `nil` à cet endroit — et encore, préférez alors `guard let` avec un message d'erreur explicite. Le chapitre 18 détaille les bonnes pratiques à ce sujet.

### `as?`

`as?` tente une conversion de type et renvoie un Optionnel : la conversion réussie donne `Optional(valeur convertie)`, l'échec donne `nil` — jamais de crash (contrairement à `as!`, vu au chapitre 43 avec le type casting complet) :

```swift
let value: Any = "Hello"

if let text = value as? String {
    print("It's a string: \(text)")
}

if let number = value as? Int {
    print("It's an int: \(number)")
} else {
    print("Not an int")   // ce cas s'exécute : value est une String, pas un Int
}
```

<div class="exercise">
<div class="exercise-title">Exercice 17.1</div>
Écrivez une fonction <code>doubleIfPossible(_ text: String) -> Int?</code> qui convertit <code>text</code> en <code>Int</code> et le multiplie par 2 s'il s'agit bien d'un nombre, ou renvoie <code>nil</code> sinon (indice : utilisez <code>if let</code> pour la conversion). Testez-la avec <code>"21"</code> et avec <code>"abc"</code>, en affichant le résultat avec l'opérateur <code>??</code> pour une valeur de repli en cas d'échec.
</div>

## 18. Optionnels avancés {#chap-18}

### Optionnels imbriqués

Un Optionnel peut lui-même contenir un autre Optionnel — typiquement le résultat d'un dictionnaire dont les valeurs sont elles-mêmes optionnelles :

```swift
let data: [String: Int?] = ["age": 30, "score": nil]

let age = data["age"]           // Int?? : le dictionnaire peut ne pas avoir la clé (Optionnel 1), et la valeur elle-même peut être nil (Optionnel 2)
```

`data["age"]` a le type `Int??` (« double Optionnel ») : le premier niveau vient de l'accès au dictionnaire (la clé peut ne pas exister), le second vient du type de la valeur stockée (`Int?`). Aplatir ce genre de structure se fait généralement avec `??` répété ou `flatMap` (vu au chapitre 9 pour les tableaux, applicable aussi aux Optionnels) :

```swift
let resolved = data["age"] ?? nil ?? -1     // -1 si la clé n'existe pas OU si sa valeur est nil
```

### `map` et `flatMap` sur les Optionnels

Comme les tableaux, un Optionnel dispose de `map` : transformer la valeur *si elle existe*, sans avoir à l'extraire manuellement :

```swift
let text: String? = "42"
let doubled = text.map { Int($0)! }          // fonctionne, mais voir la remarque ci-dessous

let safeDoubled = text.flatMap { Int($0) }.map { $0 * 2 }    // Int?, sans aucun force unwrap
print(safeDoubled ?? "invalid")                                 // 84
```

`flatMap` est nécessaire ici plutôt que `map` parce que `Int($0)` renvoie déjà un Optionnel (`Int?`) : utiliser `map` produirait un `Int??` (Optionnel imbriqué, comme ci-dessus), alors que `flatMap` « aplatit » le résultat en un simple `Int?`.

### Bonnes pratiques

Un petit guide de décision, du plus sûr au moins sûr :

1. **`guard let` / `if let`** — le choix par défaut, presque toujours possible.
2. **`??`** — quand une valeur de repli sensée existe.
3. **Optional chaining (`?.`)** — pour naviguer dans des structures imbriquées sans multiplier les `guard let`.
4. **`as?` avec `if let`/`guard let`** — jamais `as!` sauf certitude absolue et contrôlée.
5. **`!` (force unwrap)** — en dernier recours seulement, idéalement jamais en dehors de code de test ou de prototypage rapide.

### Éviter le force unwrap

Chaque fois que vous vous apprêtez à écrire `!`, demandez-vous : *que se passe-t-il si cette valeur est `nil` ?* Si la réponse est « ça ne devrait jamais arriver », préférez un `guard let ... else { fatalError("message explicite") }` — le crash reste possible, mais avec un message clair qui indique immédiatement la cause, plutôt qu'un `Fatal error: Unexpectedly found nil` générique et intraçable en production.

```swift
// Risqué : aucune information en cas d'échec
let firstUser = users.first!

// Préférable : le message explique l'invariant attendu
guard let firstUser = users.first else {
    fatalError("users ne devrait jamais être vide à ce stade du programme")
}
```

<div class="exercise">
<div class="exercise-title">Exercice 18.1</div>
Étant donné <code>let raw: [String: String] = ["price": "19.99", "quantity": "abc"]</code>, écrivez du code qui calcule le total (<code>price</code> converti en <code>Double</code>, multiplié par <code>quantity</code> converti en <code>Int</code>) en utilisant uniquement <code>guard let</code> ou <code>if let</code> — sans aucun <code>!</code> — et qui affiche un message d'erreur clair si l'une des deux conversions échoue.
</div>
