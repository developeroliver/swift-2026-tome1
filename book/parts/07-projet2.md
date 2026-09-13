# Projet 2 — 🧮 Calculatrice {#projet-2}

Ce projet met en pratique les quatre types de collections vus dans la Partie 3, dans une calculatrice en ligne de commande : un `Array` de tuples pour l'historique, un `Set` pour les opérateurs utilisés, et un `Dictionary` pour associer chaque symbole d'opérateur à son nom complet.

Le code complet se trouve dans `projects/02-calculator/` du dépôt GitHub.

### Les données du programme

```swift
let operatorNames: [String: String] = [
    "+": "addition",
    "-": "subtraction",
    "*": "multiplication",
    "/": "division"
]

var history: [(expression: String, result: Double)] = []
var usedOperators: Set<String> = []
```

Trois choix de collection, chacun pour la bonne raison :

- **`Dictionary`** pour `operatorNames` : on cherche un nom à partir d'un symbole, l'accès par clé est exactement ce qu'il faut (chapitre 11).
- **`Array` de tuples nommés** pour `history` : l'ordre des calculs doit être préservé (on veut revoir la première opération en premier), et chaque entrée regroupe deux informations liées sans mériter une vraie `struct` (chapitre 12).
- **`Set`** pour `usedOperators` : on ne s'intéresse qu'à la question « quels opérateurs, sans doublon, ai-je utilisés ? » — exactement la garantie d'unicité qu'apporte un `Set` (chapitre 10).

### La boucle principale et les commandes

Comme au Projet 1, la boucle tourne indéfiniment jusqu'à une commande d'arrêt ou une fin d'entrée. Une différence importante ici : on utilise une **boucle étiquetée** (`calculatorLoop:`), car `break` à l'intérieur d'un `switch` n'arrête que le `switch`, pas la boucle qui l'entoure :

```swift
calculatorLoop: while true {
    print("\n> ", terminator: "")

    guard let line = readLine() else {
        print("\nGoodbye!")
        break calculatorLoop
    }

    let command = line.trimmingCharacters(in: .whitespaces)

    switch command {
    case "quit", "exit":
        print("Goodbye!")
        break calculatorLoop          // sans l'étiquette, on ne sortirait que du switch
    // ...
    }
}
```

> **Piège courant** — `break` seul, dans un `switch` imbriqué dans une boucle, est un piège classique : contrairement à `continue` (qui vise toujours la boucle englobante), `break` sans étiquette à l'intérieur d'un `switch` met fin **au `switch` lui-même**, pas à la boucle. C'est une différence de comportement avec le `switch`/`break` de C ou Java qui surprend souvent. La solution : nommer la boucle (`loopName: while ...`) et écrire `break loopName`.

### Les commandes `history` et `ops`

```swift
case "history":
    if history.isEmpty {
        print("No calculations yet.")
    } else {
        for (index, entry) in history.enumerated() {
            print("\(index + 1). \(entry.expression) = \(entry.result)")
        }
    }

case "ops":
    if usedOperators.isEmpty {
        print("No operators used yet.")
    } else {
        print("Operators used: \(usedOperators.sorted().joined(separator: ", "))")
    }
```

`entry.expression` et `entry.result` réutilisent directement les noms donnés aux composants du tuple — bien plus lisible que `entry.0`/`entry.1` (chapitre 12). Pour `usedOperators`, `.sorted()` transforme le `Set` (non ordonné) en `Array` trié, uniquement pour un affichage stable et prévisible.

### Parser et calculer une expression

Le cas `default` du `switch` gère toute entrée qui n'est pas une commande connue — c'est-à-dire, en théorie, une expression à calculer :

```swift
default:
    let parts = command.split(separator: " ")

    guard parts.count == 3,
          let lhs = Double(parts[0]),
          let rhs = Double(parts[2])
    else {
        print("Invalid format. Use: <number> <operator> <number>")
        continue calculatorLoop
    }

    let symbol = String(parts[1])

    guard let operatorName = operatorNames[symbol] else {
        let known = operatorNames.keys.sorted().joined(separator: ", ")
        print("Unknown operator '\(symbol)'. Try one of: \(known)")
        continue calculatorLoop
    }
```

`command.split(separator: " ")` découpe la ligne en un `Array<Substring>` — trois éléments attendus : le nombre de gauche, le symbole, le nombre de droite. Le premier `guard` vérifie à la fois le **nombre** de composants et leur **validité numérique** en une seule expression combinée (chapitre 17 pour le détail de cette syntaxe).

Le second `guard` recherche le symbole dans `operatorNames` : c'est ce dictionnaire qui sert à la fois de **liste des opérateurs valides** et de source du nom affiché — une seule source de vérité, pas de duplication entre une liste de validation et un message d'erreur.

### Le calcul lui-même

```swift
    let result: Double
    switch symbol {
    case "+":
        result = lhs + rhs
    case "-":
        result = lhs - rhs
    case "*":
        result = lhs * rhs
    case "/":
        guard rhs != 0 else {
            print("Cannot divide by zero.")
            continue calculatorLoop
        }
        result = lhs / rhs
    default:
        continue calculatorLoop   // ne peut pas arriver : symbol vient de operatorNames
    }

    usedOperators.insert(symbol)
    let expression = "\(lhs) \(symbol) \(rhs)"
    history.append((expression: expression, result: result))
    print("= \(result) (\(operatorName))")
```

Le `case "/"` illustre un `guard` **imbriqué dans un `case`** : la division par zéro est vérifiée juste avant de calculer, avec un message dédié plutôt qu'un crash (diviser un `Double` par `0` ne provoque pas un crash comme pour un `Int`, mais produit `inf` — un résultat tout aussi peu utile pour l'utilisateur, qu'on préfère intercepter explicitement).

### Tester le programme

```bash
cd projects/02-calculator
swift run
```

Comme pour le Projet 1, on peut automatiser une session complète en lui fournissant toutes les entrées via un pipe, pratique pour vérifier rapidement chaque branche (opérations valides, division par zéro, opérateur inconnu, format invalide, commandes `history`/`ops`) :

```bash
printf "12 + 5\n10 / 0\n3 * 4\nhistory\nops\nabc\nquit\n" | swift run
```

<div class="exercise">
<div class="exercise-title">Exercice — pour aller plus loin</div>
Ajoutez une commande <code>clear</code> qui vide à la fois <code>history</code> et <code>usedOperators</code> (indice : <code>removeAll()</code> existe sur <code>Array</code> comme sur <code>Set</code>). Ajoutez ensuite l'opérateur <code>%</code> (modulo) — pensez à gérer, comme pour la division, le cas où le second opérande vaut 0.
</div>
