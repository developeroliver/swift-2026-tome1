import Foundation

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

struct Expense {
    let amount: Double
    let category: Category
    let note: String
}

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

func formatAmount(_ amount: Double) -> String {
    String(format: "$%.2f", amount)
}

let tracker = ExpenseTracker()

print("💰 Expense Tracker")
print("Commands: add <amount> <category> <note>, list, total, by-category, categories, quit")
print("Categories: \(Category.allCases.map { $0.rawValue }.joined(separator: ", "))")

trackerLoop: while true {
    print("\n> ", terminator: "")

    guard let line = readLine() else {
        print("\nGoodbye!")
        break trackerLoop
    }

    let input = line.trimmingCharacters(in: .whitespaces)
    let parts = input.split(separator: " ", maxSplits: 1)

    guard let commandWord = parts.first else {
        continue trackerLoop
    }

    let command = String(commandWord)
    let argument = parts.count > 1 ? String(parts[1]) : ""

    switch command {
    case "quit", "exit":
        print("Goodbye!")
        break trackerLoop

    case "categories":
        for category in Category.allCases {
            print("- \(category.rawValue)")
        }

    case "list":
        if tracker.expenses.isEmpty {
            print("No expenses yet.")
        } else {
            for (index, expense) in tracker.expenses.enumerated() {
                print("\(index). [\(expense.category.displayName())] \(expense.note) - \(formatAmount(expense.amount))")
            }
        }

    case "total":
        print("Total: \(formatAmount(tracker.total()))")

    case "by-category":
        let totals = tracker.totalsByCategory()
        for category in Category.allCases {
            let amount = totals[category] ?? 0
            print("\(category.displayName()): \(formatAmount(amount))")
        }

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

    default:
        print("Unknown command. Try: add, list, total, by-category, categories, quit")
    }
}
