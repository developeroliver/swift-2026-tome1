# Partie 15 — Result Builders {#partie-15}

## 50. Result Builders {#chap-50}

### Le concept

Un *result builder* transforme une **séquence d'expressions**, écrites les unes après les autres dans un bloc de code, en une **valeur unique** — sans virgules, sans `return` explicite, sans tableau littéral. Si vous avez déjà écrit du SwiftUI, vous avez déjà utilisé un result builder sans le nommer : c'est exactement le mécanisme qui permet d'empiler des vues les unes après les autres dans un `body`.

```swift
@resultBuilder
struct ArrayBuilder<Element> {
    static func buildBlock(_ components: Element...) -> [Element] {
        components
    }
}

func makeList<Element>(@ArrayBuilder<Element> _ content: () -> [Element]) -> [Element] {
    content()
}

let numbers = makeList {
    1
    2
    3
}
print(numbers)   // [1, 2, 3]
```

Sans `@resultBuilder`, il aurait fallu écrire `makeList { [1, 2, 3] }` — un simple tableau littéral. L'intérêt apparaît dès que le contenu devient plus riche : conditions, boucles, valeurs optionnelles — exactement les cas que les sections suivantes détaillent.

### `@resultBuilder`

L'attribut `@resultBuilder` marque un type comme étant un result builder — un type qui implémente une ou plusieurs méthodes `static` avec des noms précis et reconnus par le compilateur (`buildBlock`, `buildOptional`, `buildEither`...), chacune correspondant à une construction du langage utilisable à l'intérieur du bloc annoté.

### `buildBlock`

`buildBlock` est la méthode fondamentale, quasi toujours implémentée : elle reçoit **toutes** les expressions du bloc, une à une, comme des paramètres variadiques (chapitre 14), et les combine en une seule valeur de retour.

```swift
@resultBuilder
struct StringBuilder {
    static func buildBlock(_ parts: String...) -> String {
        parts.joined(separator: " ")
    }
}

func makeSentence(@StringBuilder _ content: () -> String) -> String {
    content()
}

let sentence = makeSentence {
    "Swift"
    "is"
    "great"
}
print(sentence)   // Swift is great
```

### `buildOptional`

Sans `buildOptional`, un simple `if` sans `else` à l'intérieur du bloc ne compilerait pas — le compilateur ne saurait pas quoi faire quand la condition est fausse et qu'aucune expression n'est produite pour cette branche :

```swift
extension StringBuilder {
    static func buildOptional(_ component: String?) -> String {
        component ?? ""
    }
}

func makeGreeting(includeTitle: Bool, @StringBuilder _ content: () -> String) -> String {
    content()
}

func greet(name: String, isVIP: Bool) -> String {
    makeGreeting(includeTitle: isVIP) {
        "Hello"
        if isVIP {
            "esteemed"
        }
        name
    }
}

print(greet(name: "Ada", isVIP: true))    // Hello esteemed Ada
print(greet(name: "Ada", isVIP: false))    // Hello  Ada (chaîne vide à la place de "esteemed")
```

### `buildEither`

`buildEither(first:)` et `buildEither(second:)`, toujours implémentées en paire, permettent un `if`/`else` complet à l'intérieur du bloc :

```swift
extension StringBuilder {
    static func buildEither(first component: String) -> String {
        component
    }
    static func buildEither(second component: String) -> String {
        component
    }
}

func describe(@StringBuilder _ content: () -> String) -> String {
    content()
}

let temperature = 35
let description = describe {
    if temperature > 30 {
        "It's hot"
    } else {
        "It's cool"
    }
}
print(description)   // It's hot
```

<div class="exercise">
<div class="exercise-title">Exercice 50.1</div>
Implémentez un <code>@resultBuilder</code> nommé <code>IntSumBuilder</code> dont <code>buildBlock</code> additionne tous les <code>Int</code> du bloc en un seul résultat. Ajoutez ensuite <code>buildOptional</code> pour permettre un <code>if</code> sans <code>else</code> à l'intérieur.
</div>

## 51. Créer son propre DSL Swift {#chap-51}

### Qu'est-ce qu'un DSL ?

Un DSL (*Domain-Specific Language*, langage dédié à un domaine) est une syntaxe spécialisée, construite au-dessus d'un langage général, pour exprimer un problème précis de façon plus naturelle que du code généraliste. SwiftUI est le DSL le plus connu construit avec les result builders ; cette section en construit un beaucoup plus modeste, pour du HTML.

### Un DSL HTML minimal

```swift
@resultBuilder
struct HTMLBuilder {
    static func buildBlock(_ components: String...) -> String {
        components.joined()
    }
}

func html(@HTMLBuilder _ content: () -> String) -> String {
    "<html>\(content())</html>"
}

func tag(_ name: String, @HTMLBuilder _ content: () -> String) -> String {
    "<\(name)>\(content())</\(name)>"
}

func text(_ value: String) -> String {
    value
}

let page = html {
    tag("body") {
        tag("h1") {
            text("Welcome")
        }
        tag("p") {
            text("Learning Swift result builders.")
        }
    }
}

print(page)
// <html><body><h1>Welcome</h1><p>Learning Swift result builders.</p></body></html>
```

Chaque fonction (`html`, `tag`, `text`) est une fonction Swift tout à fait ordinaire — l'illusion d'un « langage HTML dans Swift » vient entièrement de la combinaison des trailing closures (chapitre 15) et du result builder qui les assemble.

### Result builders avancés : `buildArray` et `buildLimitedAvailability`

D'autres méthodes optionnelles enrichissent encore les constructions supportées à l'intérieur du bloc :

```swift
extension HTMLBuilder {
    static func buildArray(_ components: [String]) -> String {
        components.joined()
    }
}

func list(_ items: [String]) -> String {
    html {
        tag("ul") {
            for item in items {
                tag("li") { text(item) }
            }
        }
    }
}
```

`buildArray` est ce qui permet d'utiliser une boucle `for-in` (chapitre 7) directement à l'intérieur d'un bloc annoté par le result builder — sans elle, seules des expressions statiques, écrites explicitement une par une, seraient acceptées.

### Pourquoi ce mécanisme reste rare à écrire soi-même

Écrire son propre result builder est une compétence de niveau avancé, rarement nécessaire dans du code d'application ordinaire — la plupart des développeurs Swift **utilisent** des result builders (SwiftUI, `Regex` avec `RegexBuilder`) sans jamais en **définir**. Comprendre le mécanisme reste néanmoins précieux : cela démystifie complètement la syntaxe de SwiftUI abordée au Tome 2, qui autrement pourrait sembler être de la magie du langage plutôt qu'une fonctionnalité Swift ordinaire, que vous savez maintenant reproduire vous-même.

<div class="exercise">
<div class="exercise-title">Exercice 51.1</div>
Étendez le DSL HTML avec une fonction <code>attr(_ name: String, _ value: String)</code> permettant d'ajouter des attributs à une balise, par exemple pour produire <code>&lt;a href="https://swift.org"&gt;Swift&lt;/a&gt;</code>. Réfléchissez à la signature de fonction la plus simple pour y parvenir sans complexifier le result builder lui-même.
</div>
