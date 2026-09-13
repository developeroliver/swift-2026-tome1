import Foundation

let operatorNames: [String: String] = [
    "+": "addition",
    "-": "subtraction",
    "*": "multiplication",
    "/": "division"
]

var history: [(expression: String, result: Double)] = []
var usedOperators: Set<String> = []

print("🧮 Calculator")
print("Format: <number> <operator> <number>, e.g. 12 + 5")
print("Commands: history, ops, quit")

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
        break calculatorLoop

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
    }
}
