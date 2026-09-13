# Projet 1 — 🎯 Jeu de devinettes {#projet-1}

Il est temps de rassembler tout ce que vous avez appris dans les Parties 1 et 2 : variables, types, opérateurs, conditions, boucles et ranges. L'objectif est simple : l'ordinateur choisit un nombre secret entre 1 et 100, et le joueur doit le deviner, guidé par des indices « plus grand » / « plus petit ».

Le code complet de ce projet se trouve dans `projects/01-guessing-game/` du dépôt GitHub accompagnant ce livre.

### Mise en place

Un exécutable Swift Package Manager minimal :

```swift
// Package.swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GuessingGame",
    targets: [
        .executableTarget(
            name: "GuessingGame",
            path: "Sources/GuessingGame"
        )
    ]
)
```

### Choisir le nombre secret

`Int.random(in:)` génère un entier aléatoire dans un `Range` — l'occasion de réutiliser ce qui a été vu au chapitre 8 :

```swift
let range = 1...100
let secretNumber = Int.random(in: range)
var attempts = 0
var hasWon = false
```

### La boucle de jeu

On utilise un `repeat-while` (chapitre 7) : le bloc doit s'exécuter au moins une fois, avant même de savoir si le joueur a gagné.

```swift
repeat {
    print("\nYour guess? ", terminator: "")

    guard let input = readLine() else {
        print("\nEnd of game, see you soon!")
        break
    }

    guard let guess = Int(input) else {
        print("That's not a valid number, try again.")
        continue
    }

    guard range.contains(guess) else {
        print("Stay between \(range.lowerBound) and \(range.upperBound)!")
        continue
    }

    attempts += 1

    switch guess {
    case secretNumber:
        hasWon = true
    case ..<secretNumber:
        print("📈 Higher!")
    default:
        print("📉 Lower!")
    }
} while !hasWon
```

> **Anticipation** — `readLine()` retourne un `String?` (une chaîne *optionnelle*, qui peut être absente) et `Int("...")` retourne un `Int?` (la conversion peut échouer si le texte n'est pas un nombre). Le mot-clé `guard let` permet d'extraire la valeur si elle existe, ou de sortir du bloc sinon. Les Optionnels sont le sujet complet de la Partie 5 — retenez pour l'instant simplement que `guard let ... else { ... }` vérifie une condition et quitte immédiatement (`return`, `break` ou `continue`) si elle échoue.

Trois cas sont gérés explicitement, dans l'ordre :

1. `readLine()` renvoie `nil` : il n'y a plus rien à lire sur l'entrée standard (l'utilisateur a fermé le flux). On arrête proprement la partie avec `break`, plutôt que de boucler indéfiniment.
2. Le texte saisi n'est pas un nombre valide (`Int("...")` échoue) : on prévient le joueur et on continue avec `continue`, sans compter d'essai.
3. Le nombre est hors de l'intervalle `1...100` : même traitement.

> **Piège courant** — dans une première version de ce programme, on pourrait être tenté d'écrire `guard let input = readLine(), let guess = Int(input) else { continue }` en une seule ligne pour les deux vérifications. Le problème : quand `readLine()` renvoie `nil` (fin de l'entrée), cette version relance `continue`, qui redemande une saisie... qui échouera à nouveau indéfiniment, dans une **boucle infinie**. Il faut bien distinguer « plus d'entrée du tout » (`break`, on arrête) de « entrée invalide » (`continue`, on redemande).

### Le nombre secret et le `switch`

Comparer la proposition au nombre secret avec un `switch` (chapitre 6) plutôt qu'une cascade de `if`/`else if` rend l'intention plus lisible, et réutilise le pattern matching sur les ranges (`case ..<secretNumber`) vu au chapitre 6 :

```swift
switch guess {
case secretNumber:
    hasWon = true
case ..<secretNumber:
    print("📈 Higher!")
default:
    print("📉 Lower!")
}
```

### Message final

```swift
if hasWon {
    let attemptWord = attempts > 1 ? "attempts" : "attempt"
    print("\n🎉 Well done! The number was indeed \(secretNumber). Found in \(attempts) \(attemptWord).")
}
```

L'opérateur ternaire (chapitre 5) gère élégamment l'accord singulier/pluriel de « attempt ».

### Tester le programme

```bash
cd projects/01-guessing-game
swift run
```

Pour vérifier que le programme se comporte correctement sans jouer manuellement à chaque fois, on peut lui « fournir » toutes les réponses possibles d'un coup via l'entrée standard — le programme doit alors nécessairement trouver le nombre secret et s'arrêter :

```bash
seq 1 100 | swift run
```

<div class="exercise">
<div class="exercise-title">Exercice — pour aller plus loin</div>
Modifiez le jeu pour qu'il s'arrête après un nombre maximum de tentatives (par exemple 10), en affichant un message de défaite révélant le nombre secret. Indice : ajoutez une condition supplémentaire dans la condition du <code>while</code>, par exemple <code>while !hasWon &amp;&amp; attempts &lt; 10</code>, puis testez après la boucle si le joueur a vraiment gagné ou non.
</div>
