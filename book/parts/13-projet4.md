# Projet 4 — 💰 Expense Tracker {#projet-4}

Ce projet applique directement la règle de décision du chapitre 25 : modéliser une **valeur** (une dépense individuelle) avec une `struct`, un **ensemble fini de catégories** avec un `enum`, et une **identité partagée** (le gestionnaire de toutes les dépenses) avec une `class`.

Le code complet se trouve dans `projects/04-expense-tracker/` du dépôt GitHub.

### `Category` : un enum pour un ensemble fermé de choix

```swift
enum Category: String, CaseIterable, Hashable {
    case food
    case transport
    case housing
    case leisure
    case other

    func displayName() -> String {
        rawValue.capitalized
    }
}
```

Trois choix de conformance méritent d'être expliqués :

- **`String`** (raw value) : chaque case a directement pour valeur son propre nom (`.food.rawValue == "food"`), ce qui permet de retrouver un `Category` à partir du texte tapé par l'utilisateur avec `Category(rawValue:)`.
- **`CaseIterable`** : génère automatiquement `Category.allCases`, un tableau de tous les cases — utilisé pour lister les catégories valides et pour calculer un total par catégorie, sans jamais énumérer les cas à la main (et donc sans risque d'en oublier un si une catégorie est ajoutée plus tard).
- **`Hashable`** : nécessaire pour utiliser `Category` comme **clé** d'un dictionnaire (`[Category: Double]`, dans `totalsByCategory()` plus bas) — comme vu au chapitre 10, les types utilisés dans un `Set` ou comme clés de `Dictionary` doivent être `Hashable`.

`displayName()` est une méthode ordinaire (chapitre 20), pas une property calculée (qui viendra au chapitre 27) : elle transforme le raw value technique (`"food"`, en minuscules, pratique pour le parsing) en un texte présentable (`"Food"`).

### `Expense` : une struct pour une valeur immuable

```swift
struct Expense {
    let amount: Double
    let category: Category
    let note: String
}
```

Aucun initializer personnalisé n'est nécessaire : l'initializer memberwise automatique (chapitre 19) suffit — `Expense(amount: 12.5, category: .food, note: "Lunch")`. Toutes les properties sont des `let` : une dépense, une fois enregistrée, ne change plus. C'est exactement le profil d'une bonne `struct` : une donnée, pas une identité.

### `ExpenseTracker` : une class pour une identité partagée

```swift
class ExpenseTracker {
    var expenses: [Expense] = []

    func add(_ expense: Expense) {
        expenses.append(expense)
    }

    func total() -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    func total(for category: Category) -> Double {
        expenses
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    func totalsByCategory() -> [Category: Double] {
        var totals: [Category: Double] = [:]
        for category in Category.allCases {
            totals[category] = total(for: category)
        }
        return totals
    }
}

let tracker = ExpenseTracker()
```

Pourquoi une `class` ici, et pas une `struct` ? Il n'existe qu'**un seul** `ExpenseTracker` dans tout le programme, créé une fois (`let tracker = ExpenseTracker()`) et modifié tout au long de l'exécution. Si c'était une `struct`, il faudrait la passer en `inout` (chapitre 14) à chaque fonction qui l'utilise, et une copie accidentelle briserait silencieusement la cohérence des données. Avec une `class`, `tracker` est une référence stable : peu importe combien de fonctions la manipulent, elles agissent toutes sur la **même** instance (chapitre 22).

`total(for:)` et `totalsByCategory()` enchaînent `filter` et `reduce` (chapitre 9) — aucune boucle manuelle n'est nécessaire pour agréger les données.

### La boucle de commandes

La structure reprend celle des Projets 2 et 3 (boucle étiquetée, découpage de la ligne en commande + argument). La commande `add` illustre un double niveau de découpage :

```swift
case "add":
    let tokens = argument.split(separator: " ", maxSplits: 2)

    guard tokens.count == 3,
          let amount = Double(tokens[0]),
          let category = Category(rawValue: String(tokens[1]).lowercased())
    else {
        print("Usage: add <amount> <category> <note>")
        let known = Category.allCases.map { $0.rawValue }.joined(separator: ", ")
        print("Categories: \(known)")
        continue trackerLoop
    }

    let note = String(tokens[2])
    tracker.add(Expense(amount: amount, category: category, note: note))
    print("Added.")
```

`argument.split(separator: " ", maxSplits: 2)` isole au plus trois morceaux : le montant, la catégorie, puis **le reste de la ligne tel quel** pour la note (`"add 12.50 food Lunch with a friend"` donne bien `note == "Lunch with a friend"`, pas seulement `"Lunch"`). `.lowercased()` avant `Category(rawValue:)` rend la saisie insensible à la casse (`FOOD`, `Food` et `food` fonctionnent tous les trois).

### Afficher les totaux par catégorie

```swift
case "by-category":
    let totals = tracker.totalsByCategory()
    for category in Category.allCases {
        let amount = totals[category] ?? 0
        print("\(category.displayName()): \(formatAmount(amount))")
    }
```

Itérer sur `Category.allCases` plutôt que sur les clés du dictionnaire `totals` garantit un **ordre d'affichage stable et prévisible** (rappelez-vous, chapitre 11 : un `Dictionary` n'a aucun ordre garanti) et affiche même les catégories à `$0.00`, absentes du dictionnaire si aucune dépense ne leur correspond.

### Tester le programme

```bash
cd projects/04-expense-tracker
swift run
```

```bash
printf "add 12.50 food Lunch\nadd 45 housing Rent share\nlist\ntotal\nby-category\nquit\n" | swift run
```

<div class="exercise">
<div class="exercise-title">Exercice — pour aller plus loin</div>
Ajoutez une commande <code>biggest</code> qui affiche la dépense la plus élevée enregistrée (indice : <code>tracker.expenses.max(by:)</code>, une closure comparant deux <code>Expense</code> par leur <code>amount</code>). Réfléchissez : pourquoi <code>max(by:)</code> renvoie-t-il un Optionnel, et comment devez-vous gérer le cas où la liste de dépenses est vide (Partie 5) ?
</div>
