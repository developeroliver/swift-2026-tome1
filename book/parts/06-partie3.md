# Partie 3 — Collections {#partie-3}

## 9. Arrays {#chap-9}

### Création

Un `Array` est une collection **ordonnée** de valeurs du même type :

```swift
var fruits = ["apple", "banana", "cherry"]
var scores: [Int] = [10, 20, 30]
var empty: [String] = []          // tableau vide, annotation nécessaire (chapitre 3)
let matrix = [[1, 2], [3, 4]]         // tableau de tableaux
```

### Accès

L'accès se fait par indice, en commençant à `0` :

```swift
print(fruits[0])         // apple
print(fruits.count)        // 3
print(fruits.isEmpty)        // false
```

> **Piège courant** — accéder à un indice hors limites (`fruits[10]` sur un tableau de 3 éléments) provoque un **crash immédiat à l'exécution**, pas une erreur récupérable. Contrairement à Python ou JavaScript, il n'existe pas de valeur `nil`/`undefined` de retour automatique. Vérifiez toujours `fruits.indices.contains(i)` ou utilisez `.first`/`.last` quand c'est pertinent.

### Modification

```swift
var numbers = [1, 2, 3]
numbers.append(4)              // [1, 2, 3, 4]
numbers.insert(0, at: 0)         // [0, 1, 2, 3, 4]
numbers[0] = 99                    // [99, 1, 2, 3, 4]
numbers += [5, 6]                    // [99, 1, 2, 3, 4, 5, 6]
```

Un tableau ne peut être modifié que s'il est déclaré avec `var` — cohérent avec ce qui a été vu au chapitre 3 : un `Array` est un **value type** (approfondi au chapitre 25), et `let` en interdit toute mutation, y compris `append`.

### Suppression

```swift
var letters = ["a", "b", "c", "d"]
letters.remove(at: 1)          // ["a", "c", "d"]
letters.removeLast()             // ["a", "c"]
letters.removeAll()                // []
```

### Parcours

```swift
let names = ["Ada", "Grace", "Alan"]
for name in names {
    print(name)
}

for (index, name) in names.enumerated() {
    print("\(index): \(name)")
}
```

### `map`

Transforme chaque élément et renvoie un **nouveau** tableau, de même longueur :

```swift
let numbers = [1, 2, 3, 4]
let doubled = numbers.map { $0 * 2 }      // [2, 4, 6, 8]
let asText = numbers.map { "n° \($0)" }     // ["n° 1", "n° 2", "n° 3", "n° 4"]
```

La syntaxe `{ $0 * 2 }` est une *closure* (détaillée au chapitre 15) — retenez pour l'instant que `$0` représente l'élément courant.

### `filter`

Conserve uniquement les éléments qui satisfont une condition :

```swift
let mixed = [1, -2, 3, -4, 5]
let positives = mixed.filter { $0 > 0 }     // [1, 3, 5]
```

### `reduce`

Combine tous les éléments en une seule valeur :

```swift
let values = [1, 2, 3, 4]
let total = values.reduce(0) { $0 + $1 }      // 10
let totalShort = values.reduce(0, +)             // 10 : forme condensée
```

### `compactMap`

Comme `map`, mais élimine automatiquement les résultats `nil` (voir la Partie 5 sur les Optionnels) :

```swift
let texts = ["1", "2", "abc", "4"]
let validNumbers = texts.compactMap { Int($0) }    // [1, 2, 4] : "abc" a été ignoré
```

### `flatMap`

Aplatit un tableau de tableaux en un seul tableau :

```swift
let nested = [[1, 2], [3, 4], [5]]
let flat = nested.flatMap { $0 }        // [1, 2, 3, 4, 5]
```

### `sorted`

Renvoie un nouveau tableau trié (l'original n'est pas modifié) :

```swift
let unsorted = [5, 2, 8, 1]
let ascending = unsorted.sorted()               // [1, 2, 5, 8]
let descending = unsorted.sorted(by: >)          // [8, 5, 2, 1]
```

### `contains`, `first`, `last`

```swift
let colors = ["red", "green", "blue"]
colors.contains("green")          // true
colors.first                        // Optional("red")
colors.last                          // Optional("blue")
colors.first { $0.count > 3 }          // Optional("green") : premier élément qui satisfait la condition
```

> **Note** — `.first` et `.last` renvoient un **Optionnel** (`String?`, pas `String`), parce qu'un tableau vide n'a ni premier ni dernier élément. C'est un excellent exemple concret de l'utilité des Optionnels, sujet de la Partie 5.

<div class="exercise">
<div class="exercise-title">Exercice 9.1</div>
Étant donné <code>let numbers = [4, 8, 15, 16, 23, 42]</code>, utilisez <code>filter</code> pour garder les nombres pairs, puis <code>map</code> pour les multiplier par 10, et enfin <code>reduce</code> pour en faire la somme. Essayez de chaîner les trois appels sur une seule ligne.
</div>

## 10. Sets {#chap-10}

### Création et unicité

Un `Set` est une collection **non ordonnée** dont chaque élément est **unique** :

```swift
var uniqueNumbers: Set<Int> = [1, 2, 3, 2, 1]
print(uniqueNumbers)          // {1, 2, 3} : les doublons ont disparu, l'ordre n'est pas garanti
```

Contrairement à `Array`, on ne peut pas se contenter d'une syntaxe littérale sans annotation : `let x: Set = [1, 2, 3]` ou `let x: Set<Int> = [1, 2, 3]` sont nécessaires, sinon Swift crée un `Array` par défaut.

### Ajout et suppression

```swift
var tags: Set<String> = ["swift", "ios"]
tags.insert("backend")            // {"swift", "ios", "backend"}
tags.remove("ios")                  // {"swift", "backend"}
tags.contains("swift")                // true
```

### Union, intersection, différence

Ces opérations mathématiques ensemblistes sont directement disponibles :

```swift
let a: Set<Int> = [1, 2, 3, 4]
let b: Set<Int> = [3, 4, 5, 6]

a.union(b)                  // {1, 2, 3, 4, 5, 6}
a.intersection(b)             // {3, 4}
a.subtracting(b)                // {1, 2} : les éléments de a absents de b
a.symmetricDifference(b)          // {1, 2, 5, 6} : présents dans un seul des deux
```

### Recherche

La recherche dans un `Set` (`contains`) est en moyenne bien plus rapide que dans un `Array` pour de grandes collections, car elle repose sur une table de hachage plutôt qu'un parcours séquentiel — un critère de choix important au-delà de la seule question de l'unicité.

> **Piège courant** — les éléments d'un `Set` doivent être conformes au protocole `Hashable` (chapitre 30). C'est déjà le cas de tous les types de base (`Int`, `String`, `Double`...), mais un type personnalisé (`struct`, voir chapitre 19) doit explicitement s'y conformer pour être utilisable dans un `Set`.

<div class="exercise">
<div class="exercise-title">Exercice 10.1</div>
Deux classes ont chacune un <code>Set&lt;String&gt;</code> d'élèves inscrits à une activité. Trouvez les élèves inscrits aux deux activités (intersection), puis ceux inscrits à une seule des deux (différence symétrique).
</div>

## 11. Dictionaries {#chap-11}

### Clés / valeurs

Un `Dictionary` associe des **clés uniques** à des valeurs :

```swift
var ages: [String: Int] = ["Ada": 36, "Grace": 85]
var empty: [String: String] = [:]        // dictionnaire vide
```

### Création et modification

```swift
var capitals = ["France": "Paris", "Japan": "Tokyo"]
capitals["Italy"] = "Rome"              // ajoute une nouvelle entrée
capitals["France"] = "Paris"              // écrase la valeur existante (même clé)
```

### Suppression

```swift
capitals.removeValue(forKey: "Japan")
capitals["Italy"] = nil                   // équivalent : assigner nil supprime la clé
```

### Parcours

```swift
for (country, capital) in capitals {
    print("\(capital) is the capital of \(country)")
}

for country in capitals.keys {
    print(country)
}

for capital in capitals.values {
    print(capital)
}
```

> **Piège courant** — un `Dictionary` n'a **aucun ordre garanti**. Parcourir deux fois le même dictionnaire peut donner un ordre différent d'une exécution à l'autre. Si l'ordre compte, triez explicitement les clés (`capitals.keys.sorted()`).

### Recherche

Accéder à une clé renvoie toujours un **Optionnel**, puisque la clé peut ne pas exister :

```swift
let value = capitals["Germany"]       // nil : la clé n'existe pas → pas de crash
print(value)                            // Optional(nil), affiché "nil"

let valueOrDefault = capitals["Germany", default: "Unknown"]   // "Unknown"
```

### `mapValues`

Transforme toutes les valeurs, en conservant les mêmes clés :

```swift
let prices = ["apple": 1.2, "banana": 0.8]
let discounted = prices.mapValues { $0 * 0.9 }    // ["apple": 1.08, "banana": 0.72]
```

<div class="exercise">
<div class="exercise-title">Exercice 11.1</div>
Créez un dictionnaire <code>[String: Int]</code> qui compte le nombre d'occurrences de chaque mot dans <code>let words = ["a", "b", "a", "c", "b", "a"]</code>, en itérant sur <code>words</code> et en incrémentant le compteur associé à chaque mot (indice : utilisez la syntaxe <code>dictionary[key, default: 0] += 1</code>).
</div>

## 12. Tuples {#chap-12}

### Création

Un tuple regroupe plusieurs valeurs, potentiellement de types différents, sans avoir à définir un type dédié :

```swift
let coordinates = (3, 5)                     // (Int, Int)
let person = ("Ada", 36, true)                // (String, Int, Bool)
```

### Décomposition

```swift
let (x, y) = coordinates
print(x)          // 3
print(y)           // 5

let (name, age, _) = person       // _ ignore la troisième valeur
print("\(name) is \(age)")
```

### Tuples nommés

Nommer les composants d'un tuple rend le code bien plus lisible à l'usage :

```swift
let point = (x: 10, y: 20)
print(point.x)          // 10
print(point.y)           // 20

func minMax(of numbers: [Int]) -> (min: Int, max: Int) {
    (numbers.min()!, numbers.max()!)
}

let result = minMax(of: [5, 2, 9, 1])
print("min: \(result.min), max: \(result.max)")
```

> **Anticipation** — cette fonction utilise `!` (force unwrap) sur `.min()` et `.max()`, qui renvoient des Optionnels (un tableau vide n'a ni minimum ni maximum). Ce n'est acceptable ici que parce qu'on sait par construction que `numbers` n'est jamais vide dans cet exemple ; la bonne pratique générale sera détaillée en Partie 5.

### Quand les utiliser

Les tuples sont parfaits pour des regroupements **temporaires et locaux** — par exemple, une fonction qui renvoie deux ou trois valeurs liées (comme `minMax` ci-dessus), ou une entrée de tableau d'historique (nous le ferons dans le Projet 2 qui suit). Dès que la structure de données a du sens en tant que **concept à part entière**, qu'elle sera réutilisée à plusieurs endroits, ou qu'elle a besoin de méthodes propres, préférez une vraie `struct` (chapitre 19) : un tuple non nommé accessible via `.0`, `.1` devient vite illisible, et un tuple ne peut pas avoir de méthodes.

<div class="exercise">
<div class="exercise-title">Exercice 12.1</div>
Écrivez une fonction <code>divide(_ a: Int, by b: Int) -> (quotient: Int, remainder: Int)</code> qui renvoie à la fois le quotient et le reste de la division entière de <code>a</code> par <code>b</code>, puis affichez les deux valeurs nommées séparément à l'appel.
</div>
