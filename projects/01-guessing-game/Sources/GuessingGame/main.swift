import Foundation

let range = 1...100
let secretNumber = Int.random(in: range)
var attempts = 0
var hasWon = false

print("🎯 Guessing Game")
print("I'm thinking of a number between \(range.lowerBound) and \(range.upperBound). Try to guess it!")

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

if hasWon {
    let attemptWord = attempts > 1 ? "attempts" : "attempt"
    print("\n🎉 Well done! The number was indeed \(secretNumber). Found in \(attempts) \(attemptWord).")
}
