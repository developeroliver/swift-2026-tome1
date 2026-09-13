# Partie 10 — Extensions et génériques {#partie-10}

## 34. Extensions {#chap-34}

### Ajouter des méthodes à un type existant

Une extension ajoute des fonctionnalités à un type **déjà existant** — y compris les types de la bibliothèque standard (`Int`, `String`, `Array`...), sans avoir accès à leur code source :

```swift
extension Int {
    func squared() -> Int {
        self * self
    }
}

print(5.squared())   // 25
```

### Ajouter des computed properties

Les extensions peuvent ajouter des computed properties (chapitre 27), jamais de stored properties — ajouter un espace de stockage à un type déjà compilé ailleurs (potentiellement dans la bibliothèque standard elle-même) n'est pas possible :

```swift
extension Int {
    var isEven: Bool {
        self % 2 == 0
    }
}

print(4.isEven)   // true
print(7.isEven)    // false
```

### Conformer un type existant à un protocole

C'est l'un des usages les plus puissants des extensions : faire conformer un type que vous ne contrôlez pas (d'une bibliothèque tierce, ou de la bibliothèque standard) à l'un de vos propres protocoles, **après coup** :

```swift
protocol Summarizable {
    func summary() -> String
}

extension Array: Summarizable where Element: CustomStringConvertible {
    func summary() -> String {
        map { $0.description }.joined(separator: ", ")
    }
}

let numbers = [1, 2, 3]
print(numbers.summary())   // 1, 2, 3
```

`where Element: CustomStringConvertible` est une **extension conditionnelle** : `Array` ne se conforme à `Summarizable` que lorsque son `Element` respecte lui-même cette contrainte — la syntaxe `where` sera détaillée au chapitre 36.

### Organiser son propre code avec des extensions

Au-delà d'ajouter des fonctionnalités à des types externes, les extensions sont très utilisées pour **organiser** un type volumineux que vous avez vous-même écrit — regrouper la conformance à chaque protocole dans sa propre extension, par exemple :

```swift
struct User {
    var name: String
    var email: String
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.email == rhs.email
    }
}

extension User: CustomStringConvertible {
    var description: String {
        "\(name) <\(email)>"
    }
}
```

<div class="exercise">
<div class="exercise-title">Exercice 34.1</div>
Ajoutez à <code>String</code> une extension avec une computed property <code>isPalindrome: Bool</code>, qui renvoie <code>true</code> si la chaîne se lit de la même façon à l'endroit et à l'envers (indice : <code>String(self.reversed())</code>).
</div>

## 35. Generics {#chap-35}

### Le problème que résolvent les generics

Sans generics, écrire une fonction qui échange deux valeurs obligerait à en écrire une version par type (`swapInts`, `swapStrings`, `swapDoubles`...) — une duplication évidente que les generics éliminent :

```swift
func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

var x = 1, y = 2
swapValues(&x, &y)
print(x, y)   // 2 1

var s1 = "hello", s2 = "world"
swapValues(&s1, &s2)
print(s1, s2)   // world hello
```

`T` est un **paramètre de type générique** — un espace réservé pour « n'importe quel type », déterminé au moment de l'appel. Une seule fonction fonctionne avec `Int`, `String`, ou n'importe quel autre type.

### Types génériques

Une `struct`, une `class` ou un `enum` peuvent eux aussi être génériques — vous en utilisez déjà depuis le début du livre : `Array<Element>`, `Optional<Wrapped>`, `Dictionary<Key, Value>` sont tous des types génériques de la bibliothèque standard.

```swift
struct Stack<Element> {
    private var items: [Element] = []

    mutating func push(_ item: Element) {
        items.append(item)
    }

    mutating func pop() -> Element? {
        items.popLast()
    }
}

var intStack = Stack<Int>()
intStack.push(1)
intStack.push(2)
print(intStack.pop() ?? -1)   // 2

var stringStack = Stack<String>()
stringStack.push("a")
print(stringStack.pop() ?? "empty")   // a
```

Une seule définition de `Stack`, réutilisable avec n'importe quel type d'élément — exactement le même principe que `swapValues`, appliqué à un type plutôt qu'à une fonction.

### Contraintes génériques

On peut restreindre `T` à des types respectant un protocole donné, avec `:` — indispensable dès que le corps de la fonction utilise une capacité qui n'existe pas pour *tous* les types possibles :

```swift
func largest<T: Comparable>(_ values: [T]) -> T? {
    guard var currentLargest = values.first else { return nil }
    for value in values.dropFirst() where value > currentLargest {
        currentLargest = value
    }
    return currentLargest
}

print(largest([3, 7, 2, 9, 4]) ?? 0)              // 9
print(largest(["banana", "apple", "cherry"]) ?? "")  // cherry
```

Sans `T: Comparable`, l'opérateur `>` ne compilerait pas : rien ne garantit que « n'importe quel type » sache se comparer. La contrainte documente et impose exactement ce dont la fonction a besoin.

<div class="exercise">
<div class="exercise-title">Exercice 35.1</div>
Écrivez une fonction générique <code>allEqual&lt;T: Equatable&gt;(_ values: [T]) -> Bool</code> qui renvoie <code>true</code> si tous les éléments du tableau sont égaux entre eux (ou si le tableau est vide ou n'a qu'un élément).
</div>

## 36. Generics avancés {#chap-36}

### La clause `where`

`where`, déjà rencontrée avec `switch` (chapitre 6) et `for-in` (chapitre 7), exprime des contraintes génériques plus riches qu'un simple `:` — notamment des relations **entre plusieurs** paramètres de type :

```swift
func haveSameElements<C1: Collection, C2: Collection>(
    _ first: C1, _ second: C2
) -> Bool where C1.Element: Equatable, C1.Element == C2.Element {
    guard first.count == second.count else { return false }
    return zip(first, second).allSatisfy { $0 == $1 }
}

print(haveSameElements([1, 2, 3], [1, 2, 3]))     // true
print(haveSameElements([1, 2, 3], ["1", "2"]))     // ERREUR de compilation : types d'Element incompatibles
```

`C1.Element == C2.Element` est une contrainte que `:` seul ne peut pas exprimer : elle relie l'associated type (chapitre 33) de deux paramètres génériques différents.

### Associated types et generics

Les fonctions génériques et les protocoles à `associatedtype` se combinent naturellement — c'est précisément ce qui a été anticipé au chapitre 33 avec `printAll<C: Container>` :

```swift
protocol Container {
    associatedtype Item
    var items: [Item] { get }
}

func firstItem<C: Container>(of container: C) -> C.Item? {
    container.items.first
}
```

`C.Item` — le point relie le paramètre générique `C` à son associated type `Item` — se lit « le type `Item` associé à ce `Container` en particulier ».

### Protocoles génériques et type constraints

Combiner plusieurs contraintes sur un même paramètre générique se fait avec `&`, comme pour la composition de protocoles au chapitre 32 :

```swift
func describe<T: Equatable & CustomStringConvertible>(_ value: T) -> String {
    "Value: \(value.description)"
}
```

`T` doit ici respecter **à la fois** `Equatable` et `CustomStringConvertible` — aucun des deux seuls ne suffirait pour ce que la fonction a besoin de faire.

### Generics vs `Any`

Il peut être tentant de contourner les generics avec `Any` (chapitre 17), qui accepte litéralement n'importe quel type :

```swift
func printAnything(_ value: Any) {
    print(value)
}
```

Mais `Any` fait perdre **toute information de type** : impossible de garantir que deux valeurs `Any` sont du même type, impossible d'utiliser leurs méthodes propres sans un cast (`as?`, chapitre 43) risqué et verbeux. Les generics, eux, préservent le type exact **à la compilation**, avec les vérifications et l'autocomplétion qui vont avec — c'est toute la différence entre `Any`, qui déplace les problèmes à l'exécution, et les generics, qui les résolvent avant même que le programme tourne.

<div class="exercise">
<div class="exercise-title">Exercice 36.1</div>
Écrivez une fonction générique <code>merge&lt;K, V&gt;(_ first: [K: V], _ second: [K: V]) -> [K: V]</code> (avec la contrainte nécessaire sur <code>K</code> pour qu'il soit utilisable comme clé de dictionnaire) qui fusionne deux dictionnaires, les valeurs du second l'emportant en cas de clé commune.
</div>
