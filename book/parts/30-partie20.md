# Partie 20 — Niveau expert {#partie-20}

## 65. Comprendre le compilateur Swift {#chap-65}

### Le pipeline de compilation

Depuis le chapitre 1, ce livre traite la compilation comme une boîte noire : du code source entre, un exécutable sort. En réalité, `swiftc` traverse plusieurs étapes distinctes, chacune produisant une représentation différente du même programme :

```text
Code source (.swift)
    ↓  Parsing
AST (Abstract Syntax Tree)
    ↓  Sema (analyse sémantique)
AST typé et vérifié
    ↓  SILGen
SIL (Swift Intermediate Language)
    ↓  Optimisations SIL
SIL optimisé
    ↓  IRGen (LLVM)
LLVM IR
    ↓  Backend LLVM
Code machine natif
```

### Type checking

L'étape de *Sema* (analyse sémantique) est celle qui donne à Swift sa réputation de langage strict : c'est elle qui vérifie que chaque expression a un type cohérent, que chaque appel de fonction correspond à une signature existante, que chaque `guard`/`if let` couvre bien les cas d'Optionnels — l'immense majorité des erreurs rencontrées dans ce livre (« cannot convert value of type... », « missing argument for parameter... ») viennent de cette étape précise.

### SIL : une représentation propre à Swift

**SIL** (*Swift Intermediate Language*) est une représentation intermédiaire propre à Swift, plus abstraite que le code machine mais plus concrète que le code source — c'est à ce niveau que des optimisations spécifiquement Swift ont lieu : élision de retenues ARC redondantes (chapitre 39), spécialisation de generics (chapitre 35, transformer une fonction générique en versions concrètes optimisées pour chaque type utilisé réellement), inlining de closures. Un développeur curieux peut inspecter cette représentation directement :

```bash
swiftc -emit-sil main.swift -o /dev/stdout | head -50
```

### Modules

Un *module* est l'unité de compilation la plus large de Swift — généralement, un target SPM entier (chapitre 60) devient un seul module. Le compilateur traite un module dans son ensemble (*whole module optimization*), ce qui lui permet des optimisations impossibles fichier par fichier : par exemple, `final` (chapitre 23) et `private` (chapitre 42) permettent au compilateur de résoudre statiquement des appels qui nécessiteraient sinon une résolution dynamique coûteuse.

<div class="exercise">
<div class="exercise-title">Exercice 65.1</div>
Exécutez <code>swiftc -emit-sil</code> sur un petit fichier contenant une seule fonction simple (par exemple <code>func square(_ n: Int) -> Int { n * n }</code>) et observez la sortie. Sans nécessairement tout comprendre, identifiez au moins le nom de la fonction dans le SIL généré.
</div>

## 66. Memory & performance {#chap-66}

### Stack et heap

Deux zones de mémoire aux caractéristiques très différentes. La **pile** (*stack*) est extrêmement rapide (une simple avancée/recul d'un pointeur) mais de taille limitée et de durée de vie strictement liée à la fonction en cours ; le **tas** (*heap*) est plus lent à allouer mais permet une durée de vie arbitraire et une taille dynamique. Une `class` (chapitre 22), par nature partagée par référence, est **toujours** allouée sur le tas ; une `struct` (chapitre 19), quand c'est possible, est allouée sur la pile — l'une des raisons de performance qui motivent la préférence de Swift pour les `struct` (chapitre 25).

### Allocation

Chaque allocation sur le tas a un coût réel : trouver un emplacement libre, gérer sa libération éventuelle (ARC, chapitre 39). Une fonction qui crée des milliers de petites instances de `class` en boucle paie ce coût à chaque itération ; la même logique avec des `struct` l'évite presque entièrement.

### Copy-on-write en détail

Le chapitre 25 a présenté le résultat observable du copy-on-write ; voici le mécanisme sous-jacent, reproductible avec la fonction `isKnownUniquelyReferenced` :

```swift
final class Box {
    var value: Int
    init(_ value: Int) { self.value = value }
}

struct Container {
    private var box: Box
    init(_ value: Int) { box = Box(value) }

    var value: Int {
        get { box.value }
        set {
            if !isKnownUniquelyReferenced(&box) {
                box = Box(newValue)     // une autre Container partage encore ce Box : on copie avant de modifier
            } else {
                box.value = newValue      // personne d'autre ne référence ce Box : modification directe, sans copie
            }
        }
    }
}

var a = Container(1)
var b = a          // b partage le même Box interne que a, pour l'instant
b.value = 42          // déclenche la copie, car isKnownUniquelyReferenced(&box) renvoie false ici
print(a.value, b.value)   // 1 42 : a est resté intact
```

C'est très exactement ce mécanisme, appliqué à des structures de données bien plus complexes, qu'`Array`, `Dictionary` et `Set` utilisent en interne — une `struct` publique (value semantics garanties) enveloppant une `class` privée (stockage réellement partagé jusqu'à la première mutation).

### Performance des collections

| Opération | `Array` | `Set` | `Dictionary` |
|---|---|---|---|
| Accès par indice/clé | O(1) | — | O(1) en moyenne |
| Recherche (`contains`) | O(n) | O(1) en moyenne | O(1) en moyenne (clé) |
| Insertion à la fin | O(1) amorti | O(1) en moyenne | O(1) en moyenne |
| Insertion au début/milieu | O(n) | — | — |
| Ordre préservé | Oui | Non | Non |

> **Piège courant** — utiliser `Array.contains` en boucle sur une grande collection (recherche répétée d'appartenance) est une source de ralentissement fréquente et facile à corriger : remplacer l'`Array` par un `Set` (chapitre 10) transforme une recherche O(n) en O(1) en moyenne, souvent sans aucun autre changement de logique.

<div class="exercise">
<div class="exercise-title">Exercice 66.1</div>
Reprenez l'exemple <code>Container</code> ci-dessus et ajoutez un <code>print("Copying")</code> dans la branche qui copie réellement. Créez trois variables partageant progressivement le même <code>Container</code>, modifiez-en une, et comptez combien de copies réelles ont lieu.
</div>

## 67. Swift Evolution {#chap-67}

### SE proposals

Chaque fonctionnalité de Swift rencontrée dans ce livre — `async`/`await` (Partie 16), les result builders (Partie 15), les macros (Partie 17) — est passée par le même processus public et documenté : une **SE proposal** (*Swift Evolution proposal*), un document structuré décrivant précisément le problème, la solution proposée, les alternatives envisagées et rejetées, et l'impact sur le code existant.

### Comment Swift évolue

Le processus, en résumé :

1. **Pitch** — une idée informelle est discutée sur le forum public [forums.swift.org](https://forums.swift.org).
2. **Proposal** — l'idée est formalisée en document structuré, avec un numéro (`SE-0296` pour `async`/`await`, par exemple).
3. **Review** — une période de commentaires publics, ouverte à quiconque.
4. **Décision** — le *Swift Core Team* (ou, pour certains sujets, l'ensemble des *Language Steering Group*) accepte, rejette, ou demande une révision.
5. **Implémentation** — une fois acceptée, la fonctionnalité est implémentée dans le compilateur open-source, sur GitHub.

### Lire une proposition Swift Evolution

Toutes les propositions sont publiques sur [github.com/swiftlang/swift-evolution](https://github.com/swiftlang/swift-evolution/tree/main/proposals). Chaque document suit une structure standard : *Introduction*, *Motivation*, *Proposed solution*, *Detailed design*, *Source compatibility*, *Alternatives considered*. La section *Alternatives considered* est souvent la plus instructive : elle explique pourquoi le langage a la forme qu'il a, plutôt qu'une autre forme tout aussi plausible.

> **Pourquoi s'y intéresser** — comprendre qu'une fonctionnalité vient d'un processus ouvert, avec des alternatives sérieusement pesées et documentées, change la façon de l'apprendre : au lieu de mémoriser une syntaxe arbitraire, on comprend le **problème** qu'elle résout, ce qui en facilite l'usage correct et la comparaison avec d'anciennes approches (par exemple, pourquoi `async`/`await` a remplacé les closures `@escaping` pour la plupart des usages, sans les rendre obsolètes pour autant — comparez le Projet 5 et le Projet 7 de ce livre).

<div class="exercise">
<div class="exercise-title">Exercice 67.1</div>
Trouvez sur le dépôt Swift Evolution la proposition qui a introduit les <code>async let</code> (chapitre 54) ou les <code>Property Wrappers</code> (Partie 14). Lisez la section « Alternatives considered » et notez une alternative que vous n'auriez pas envisagée vous-même.
</div>

## 68. API Design Guidelines {#chap-68}

### Clarté au point d'usage

Le principe directeur des *Swift API Design Guidelines* officielles : le code doit être clair **à l'endroit où il est lu**, l'appel de fonction, pas seulement à l'endroit où il est déclaré :

```swift
// Peu clair à l'appel :
func remove(_ x: Int, _ y: [Int]) -> [Int]
remove(3, [1, 2, 3, 4])   // remove QUOI, de QUOI, exactement ?

// Clair à l'appel, grâce aux noms de paramètres :
func removing(_ element: Int, from array: [Int]) -> [Int]
removing(3, from: [1, 2, 3, 4])   // se lit presque comme une phrase anglaise
```

### Grammaire des noms : verbe vs nom

Une convention précise distingue les méthodes qui **mutent** (chapitre 19) de celles qui renvoient une **nouvelle** valeur, illustrée par une paire déjà rencontrée au chapitre 9 :

```swift
var numbers = [3, 1, 2]
numbers.sort()              // verbe à l'impératif : mute numbers sur place
let sorted = numbers.sorted() // participe passé : renvoie une nouvelle valeur, numbers inchangé
```

Cette paire *verbe/participe passé* (`sort`/`sorted`, `append`/`appending`, `remove`/`removing`) est une convention systématique dans toute la bibliothèque standard — la respecter dans son propre code signale immédiatement, sans documentation, si une méthode mute ou non.

### Éviter les abréviations

```swift
// À éviter :
func calc(_ v: Double, _ r: Double) -> Double

// Préféré :
func calculateTotal(value: Double, rate: Double) -> Double
```

Swift favorise des noms complets et explicites plutôt que des abréviations économes en caractères — un choix de lisibilité assumé depuis la philosophie même du langage (chapitre 1 : « clarity over brevity »).

### Concevoir des API réutilisables

Quelques règles pratiques, déjà appliquées tout au long des projets de ce livre : préférer les protocoles aux types concrets dans les signatures publiques (chapitre 32, illustré par `APIRequest` au Projet 5) ; ne rendre `public` (chapitre 42) que ce qui doit réellement l'être, jamais par défaut ; documenter avec `///` (chapitre 2) toute déclaration publique, puisqu'un utilisateur de la bibliothèque n'a pas accès à son code source pour deviner l'intention.

<div class="exercise">
<div class="exercise-title">Exercice 68.1</div>
Reprenez la signature <code>func check&lt;V: Validator&gt;(_ validator: V, _ value: V.Value, label: String)</code> du Projet 6. Est-elle conforme aux principes de ce chapitre ? Proposez, si nécessaire, un renommage qui la rendrait plus claire à l'appel.
</div>

## 69. Patterns Swift {#chap-69}

Les patterns de conception ne sont pas propres à Swift, mais leur expression change avec les outils du langage — voici les plus courants, exprimés de façon idiomatique.

### Factory

```swift
protocol Vehicle { var name: String { get } }
struct Car: Vehicle { let name = "Car" }
struct Bike: Vehicle { let name = "Bike" }

enum VehicleFactory {
    static func make(kind: String) -> Vehicle? {
        switch kind {
        case "car": return Car()
        case "bike": return Bike()
        default: return nil
        }
    }
}
```

### Builder

```swift
final class PizzaBuilder {
    private var pizza = Pizza()
    func addTopping(_ topping: String) -> PizzaBuilder {
        pizza.toppings.append(topping)
        return self
    }
    func build() -> Pizza { pizza }
}

let pizza = PizzaBuilder().addTopping("cheese").addTopping("olives").build()
```

Chaque méthode renvoie `self`, permettant le chaînage — une construction progressive et lisible d'un objet complexe, comparable à ce que les result builders (Partie 15) offrent avec une syntaxe encore plus déclarative.

### Strategy

```swift
protocol DiscountStrategy {
    func apply(to price: Double) -> Double
}
struct PercentageDiscount: DiscountStrategy {
    let percentage: Double
    func apply(to price: Double) -> Double { price * (1 - percentage / 100) }
}

struct Checkout {
    let strategy: DiscountStrategy
    func total(for price: Double) -> Double { strategy.apply(to: price) }
}
```

Le comportement (`strategy`) est injecté plutôt que codé en dur — directement le même principe d'inversion de dépendance vu au chapitre 32.

### Repository

```swift
protocol UserRepository {
    func find(id: Int) -> String?
}
struct InMemoryUserRepository: UserRepository {
    let users: [Int: String]
    func find(id: Int) -> String? { users[id] }
}
```

Un `Repository` isole l'accès aux données (base de données, réseau, mémoire) derrière un protocole — la même technique que `DataStore` du chapitre 64, appliquée spécifiquement à la persistance de données métier.

### Dependency Injection

```swift
struct ReportGenerator {
    let repository: UserRepository        // injectée via l'initializer, pas construite en interne
    func report(for id: Int) -> String {
        "Report for \(repository.find(id: id) ?? "unknown")"
    }
}
```

### Observer

```swift
final class Publisher {
    private var handlers: [(String) -> Void] = []
    func subscribe(_ handler: @escaping (String) -> Void) {
        handlers.append(handler)
    }
    func publish(_ event: String) {
        for handler in handlers { handler(event) }
    }
}
```

Plusieurs observateurs réagissent au même événement, sans que `Publisher` ait besoin de les connaître individuellement — le principe de base derrière `willSet`/`didSet` (chapitre 28) et, au Tome 2, l'observation de state en SwiftUI.

### Result type

```swift
enum AppError: Error { case notFound }

func findUser(id: Int) -> Result<String, AppError> {
    id == 1 ? .success("Ada") : .failure(.notFound)
}
```

Déjà largement pratiqué depuis le Projet 5 : `Result<Success, Failure>` rend les deux issues possibles d'une opération également visibles dans la signature de la fonction, sans recourir à `throws` quand ce n'est pas souhaité (par exemple, pour transporter une erreur au sein d'une closure `@escaping`, où `throws` ne s'applique pas directement).

<div class="exercise">
<div class="exercise-title">Exercice 69.1</div>
Identifiez, parmi les projets déjà construits dans ce livre, un endroit où l'un de ces six patterns était déjà présent sans être nommé explicitement dans le texte du chapitre correspondant.
</div>

## 70. Écrire du Swift idiomatique {#chap-70}

### Code lisible

Un code Swift lisible privilégie systématiquement `let` sur `var` (chapitre 3), des noms complets plutôt que des abréviations (chapitre 68), et une structure qui évite l'imbrication profonde — `guard` en tête de fonction (chapitre 17) plutôt que des `if` en cascade.

### Code sûr

La sécurité de type de Swift n'a de valeur que si elle n'est pas contournée : éviter le force unwrap (`!`, chapitre 17) et `try!` (chapitre 38) en dehors de garanties réellement absolues ; préférer des `enum` (chapitre 20) à des combinaisons de booléens et d'Optionnels pour modéliser un état ; laisser le compilateur détecter les erreurs plutôt que de les découvrir à l'exécution.

### Code performant

Préférer `struct` à `class` sauf besoin réel d'identité partagée (chapitre 25) ; choisir la bonne collection pour l'opération dominante (chapitre 66 : `Set` pour la recherche fréquente, `Array` pour l'ordre et l'itération) ; ne pas prématurément optimiser au détriment de la lisibilité — mesurer avant d'optimiser reste une règle universelle, pas propre à Swift.

### Anti-patterns à éviter

- **Stringly-typed code** — utiliser des `String` brutes là où un `enum` (chapitre 20) éliminerait une catégorie entière de fautes de frappe silencieuses.
- **`Any` par facilité** — céder à `Any` (chapitre 17) pour éviter d'écrire un generic (chapitre 35) ou un protocole (chapitre 30), perdant toutes les garanties de type au passage.
- **Classes par réflexe** — utiliser `class` par habitude venue d'un autre langage, là où une `struct` suffirait et serait plus sûre (chapitre 25).
- **Ignorer les avertissements du compilateur** — un `warning` sur une `var` jamais modifiée (chapitre 3) ou un `Sendable` manquant (chapitre 57) signale presque toujours un vrai problème, pas du bruit.

### L'approche « Swifty »

Ce dernier chapitre referme la boucle ouverte au chapitre 1 : la philosophie de Swift — sécurité, clarté, performance — n'est pas une liste de règles abstraites, mais ce que chaque chapitre de ce livre a tenté d'illustrer concrètement, projet après projet. Écrire du Swift idiomatique, au fond, consiste à faire confiance aux outils que le langage met à disposition (le typage strict, les Optionnels, la value semantics, la concurrence structurée) plutôt qu'à les contourner — et c'est exactement ce qui rend le code Swift, bien écrit, aussi difficile à faire planter qu'il est agréable à lire.

<div class="exercise">
<div class="exercise-title">Exercice final du Tome 1</div>
Reprenez l'un des sept projets de ce livre et relisez-le entièrement à la lumière de ce chapitre : y trouvez-vous un force unwrap qui pourrait être évité, une <code>class</code> qui pourrait être une <code>struct</code>, ou une abréviation qui mériterait d'être explicitée ? Le Projet final, qui suit, rassemble maintenant tout ce que vous avez appris dans une seule application complète.
</div>
