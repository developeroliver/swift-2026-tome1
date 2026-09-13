# Projet 3 — ✅ Todo CLI {#projet-3}

Ce projet met en pratique les fonctions et closures de la Partie 4 dans une application de liste de tâches persistante : les tâches survivent d'une exécution à l'autre, sauvegardées dans un simple fichier texte.

Le code complet se trouve dans `projects/03-todo-cli/` du dépôt GitHub.

> **Anticipation** — ce projet manipule des valeurs qui peuvent être absentes (le contenu d'un fichier qui n'existe pas encore, une conversion de texte en `Int` qui peut échouer). Ces valeurs sont des **Optionnels**, le sujet complet de la Partie 5, juste après ce projet. Comme au Projet 1, on se contente ici de `guard let` pour les extraire ; comprendre *pourquoi* ce mécanisme existe viendra au chapitre suivant.

### Choix de structure de données

Sans encore de `struct` (Partie 6), une tâche est représentée par un tuple nommé (chapitre 12) : `(text: String, isDone: Bool)`. La liste complète est donc `[(text: String, isDone: Bool)]` — un `Array` de tuples, comme l'historique du Projet 2.

### Charger les tâches depuis un fichier

```swift
func loadTodos(from path: String) -> [(text: String, isDone: Bool)] {
    guard let data = FileManager.default.contents(atPath: path),
          let content = String(data: data, encoding: .utf8)
    else {
        return []
    }

    return content.split(separator: "\n").map { line in
        let isDone = line.hasPrefix("[x]")
        let text = line.dropFirst(4).trimmingCharacters(in: .whitespaces)
        return (text: text, isDone: isDone)
    }
}
```

`FileManager.default.contents(atPath:)` renvoie `Data?` — `nil` si le fichier n'existe pas encore (premier lancement du programme). `String(data:encoding:)` renvoie lui aussi un Optionnel. Le double `guard let` gère les deux échecs possibles d'un coup : dans les deux cas, on renvoie simplement une liste vide plutôt qu'une erreur — un fichier absent n'est pas une situation anormale ici, juste un point de départ.

Chaque ligne sauvegardée a le format `[x] texte` ou `[ ] texte` (4 caractères de préfixe dans les deux cas) ; `.map` (chapitre 9, revu au chapitre 15 comme closure) transforme chaque ligne du fichier en un tuple `(text:, isDone:)`.

### Sauvegarder les tâches

```swift
func saveTodos(_ todos: [(text: String, isDone: Bool)], to path: String) {
    let lines = todos.map { "\($0.isDone ? "[x]" : "[ ]") \($0.text)" }
    let content = lines.joined(separator: "\n")
    FileManager.default.createFile(atPath: path, contents: Data(content.utf8))
}
```

L'opération inverse de `loadTodos` : chaque tuple redevient une ligne de texte. `saveTodos` est appelée après **chaque** modification (ajout, suppression, changement d'état) plutôt qu'une seule fois à la fin — si le programme s'arrête de façon inattendue, aucune tâche n'est perdue.

### Fonctions qui modifient la liste : `inout`

Ajouter, cocher ou supprimer une tâche doit modifier la variable `todos` du programme principal directement — exactement le cas d'usage d'`inout` (chapitre 14) :

```swift
func addTodo(_ text: String, to todos: inout [(text: String, isDone: Bool)]) {
    todos.append((text: text, isDone: false))
}

func toggleTodo(at index: Int, in todos: inout [(text: String, isDone: Bool)]) -> Bool {
    guard todos.indices.contains(index) else { return false }
    todos[index].isDone.toggle()
    return true
}

func removeTodo(at index: Int, from todos: inout [(text: String, isDone: Bool)]) -> Bool {
    guard todos.indices.contains(index) else { return false }
    todos.remove(at: index)
    return true
}
```

`toggleTodo` et `removeTodo` renvoient un `Bool` qui indique si l'opération a réussi — `false` si l'indice fourni par l'utilisateur n'existe pas dans le tableau. C'est ce `Bool` qui permet à la boucle principale d'afficher un message d'erreur clair plutôt que de laisser le programme planter sur un indice invalide.

### La boucle principale

```swift
todoLoop: while true {
    print("\n> ", terminator: "")

    guard let line = readLine() else {
        saveTodos(todos, to: filePath)
        print("\nSaved. Goodbye!")
        break todoLoop
    }

    let input = line.trimmingCharacters(in: .whitespaces)
    let parts = input.split(separator: " ", maxSplits: 1)

    guard let commandWord = parts.first else {
        continue todoLoop
    }

    let command = String(commandWord)
    let argument = parts.count > 1 ? String(parts[1]) : ""
    // ...
}
```

`split(separator: " ", maxSplits: 1)` découpe la ligne en **au plus deux morceaux** : la commande, puis le reste tel quel (important pour `add Buy milk and eggs`, où l'argument entier — espaces compris — doit rester une seule chaîne, pas être redécoupé mot par mot).

### Combiner `guard let` et une condition booléenne

Le traitement de `done` et `remove` illustre une syntaxe utile : combiner une liaison optionnelle et une vérification booléenne dans un seul `guard`, séparées par une virgule :

```swift
case "done":
    guard let index = Int(argument), toggleTodo(at: index, in: &todos) else {
        print("Usage: done <valid index>")
        continue todoLoop
    }
    saveTodos(todos, to: filePath)
    print("Updated.")
```

Les deux conditions doivent être vraies pour continuer : `argument` doit être convertible en `Int`, **et** cet indice doit exister dans `todos`. Si l'une des deux échoue, un seul et même message d'erreur s'affiche — inutile de distinguer « ce n'est pas un nombre » de « ce nombre n'est pas un indice valide », le résultat pour l'utilisateur est le même.

### Tester le programme

```bash
cd projects/03-todo-cli
swift run
```

Pour vérifier la persistance, lancez le programme, ajoutez des tâches, quittez avec `quit`, puis relancez `swift run` : la liste doit être conservée, chargée depuis `todos.txt`. Automatiser une session complète fonctionne comme pour les projets précédents :

```bash
printf "add Buy milk\nadd Write book\ndone 1\nlist\nquit\n" | swift run
```

<div class="exercise">
<div class="exercise-title">Exercice — pour aller plus loin</div>
Ajoutez une commande <code>clear-done</code> qui supprime d'un coup toutes les tâches déjà cochées, en utilisant <code>filter</code> (chapitre 9) pour ne garder que celles où <code>isDone == false</code> plutôt qu'une boucle de suppression manuelle.
</div>
