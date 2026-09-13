# Partie 17 — Macros {#partie-17}

## 58. Introduction aux macros {#chap-58}

### Pourquoi les macros ?

Une macro Swift génère du code **à la compilation**, à partir du code que vous écrivez — une forme de métaprogrammation qui élimine du texte répétitif tout en gardant le résultat final entièrement visible, débogable, et vérifié par le compilateur comme n'importe quel autre code. Introduites en 2023 (Swift 5.9), les macros s'attaquent à un problème que les générateurs de code externes (scripts, outils tiers) résolvaient auparavant de façon bien moins intégrée : produire du code Swift ordinaire, sans étape de build séparée, sans fichier généré à maintenir à part.

### Compile-time metaprogramming

La distinction essentielle : une macro ne s'exécute **jamais** au moment où votre programme tourne — elle s'exécute pendant la **compilation**, transforme une portion de syntaxe en une autre, puis disparaît complètement. Le code compilé final ne contient que le résultat de cette expansion, comme si vous l'aviez écrit à la main.

```swift
let (result, code) = #stringify(2 + 3)
// après expansion par le compilateur, équivaut exactement à :
// let (result, code) = (2 + 3, "2 + 3")

print(result)   // 5
print(code)       // "2 + 3"
```

`#stringify` (fournie dans le gabarit officiel de macro de Swift) illustre bien le principe : elle prend une expression et produit à la fois sa valeur **et** le texte source qui l'a produite — quelque chose d'impossible à écrire comme une simple fonction, puisqu'une fonction ne voit jamais le code source de ses arguments, seulement leurs valeurs déjà évaluées.

### Deux catégories de macros

Swift distingue les macros **freestanding** (autonomes, invoquées avec `#`, comme `#stringify` ci-dessus) des macros **attached** (attachées à une déclaration existante, invoquées avec `@`, comme `@Observable` de l'écosystème SwiftUI). La section suivante détaille les deux.

<div class="exercise">
<div class="exercise-title">Exercice 58.1</div>
Sans écrire de code : pourquoi une macro s'exécutant à la compilation ne peut-elle jamais provoquer de ralentissement du programme final à l'exécution, contrairement à une fonction ordinaire ?
</div>

## 59. Macros Swift {#chap-59}

### Freestanding macros

Une macro *freestanding* s'utilise directement comme une expression ou une instruction, préfixée par `#` :

```swift
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) =
    #externalMacro(module: "StringifyMacroMacros", type: "StringifyMacro")
```

Cette déclaration ne contient **aucune logique** : elle se contente de nommer la macro et de préciser où trouver son implémentation réelle (`#externalMacro`), dans un module séparé — le *compiler plugin*, détaillé plus bas.

### Attached macros

Une macro *attached* s'applique à une déclaration existante (une property, une fonction, un type) avec `@`, et peut y **ajouter** du code plutôt que de le remplacer :

```swift
@attached(member)
public macro AddDescription() = #externalMacro(module: "MyMacros", type: "AddDescriptionMacro")

@AddDescription
struct Point {
    let x: Double
    let y: Double
}
// après expansion, Point obtient par exemple une méthode description() générée automatiquement,
// en plus de x et y écrits à la main
```

### Expansion

Le mécanisme d'*expansion* — remplacer l'appel de macro par le code généré — se produit entièrement dans un programme séparé appelé un **compiler plugin**, écrit avec la bibliothèque `SwiftSyntax`, qui analyse le code source sous forme d'arbre syntaxique et produit le code de remplacement. Ce plugin s'exécute pendant la compilation de votre projet, jamais dans l'application finale.

### Créer une macro : structure d'un projet

Swift Package Manager fournit un gabarit dédié :

```bash
swift package init --type macro --name StringifyMacro
```

Cette commande génère un package avec **quatre** cibles distinctes — la structure minimale incontournable pour toute macro :

```text
StringifyMacro/
├── Sources/
│   ├── StringifyMacro/            <- déclare la macro (ce que les utilisateurs importent)
│   └── StringifyMacroMacros/       <- implémente l'expansion (le compiler plugin)
├── Tests/
│   └── StringifyMacroTests/          <- teste l'expansion générée
└── Sources/StringifyMacroClient/       <- exemple d'utilisation
```

L'implémentation elle-même, dans `StringifyMacroMacros` :

```swift
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        return "(\(argument), \(literal: argument.description))"
    }
}

@main
struct StringifyMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self
    ]
}
```

`expansion(of:in:)` reçoit `node`, une représentation structurée du code source à l'endroit où la macro est invoquée (via `SwiftSyntax`), et renvoie une chaîne de remplacement — ici, un tuple contenant l'expression originale et sa représentation textuelle (`argument.description`).

Utilisée depuis un autre module :

```swift
import StringifyMacro

let a = 17
let b = 25
let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")
// The value 42 was produced by the code "a + b"
```

> **Dans la pratique** — écrire une macro personnalisée reste une compétence de niche, comparable à l'écriture d'un result builder (chapitre 50) : la grande majorité du code Swift **utilise** des macros existantes (`@Observable`, `#Predicate`, `#stringify`) sans jamais en créer. `SwiftSyntax`, la bibliothèque sous-jacente, est un projet à part entière — comprendre l'arbre syntaxique qu'elle manipule dépasse le cadre de ce livre, mais savoir qu'une macro n'est « que » du code Swift qui transforme du code Swift démystifie complètement ce qui pourrait autrement sembler être une fonctionnalité opaque du compilateur.

<div class="exercise">
<div class="exercise-title">Exercice 59.1</div>
Générez le gabarit avec <code>swift package init --type macro --name StringifyMacro</code>, compilez-le avec <code>swift build</code>, puis exécutez le client fourni avec <code>swift run StringifyMacroClient</code>. Modifiez ensuite l'expression passée à <code>#stringify</code> dans <code>main.swift</code> et observez comment le texte affiché change en conséquence.
</div>
