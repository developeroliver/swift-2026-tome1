import Foundation

let range = 1...100
let secretNumber = Int.random(in: range)
var attempts = 0
var hasWon = false

print("🎯 Jeu de devinettes")
print("Je pense à un nombre entre \(range.lowerBound) et \(range.upperBound). À toi de le trouver !")

repeat {
    print("\nTa proposition ? ", terminator: "")

    guard let entree = readLine() else {
        print("\nFin de la partie, à bientôt !")
        break
    }

    guard let proposition = Int(entree) else {
        print("Ce n'est pas un nombre valide, réessaie.")
        continue
    }

    guard range.contains(proposition) else {
        print("Reste entre \(range.lowerBound) et \(range.upperBound) !")
        continue
    }

    attempts += 1

    switch proposition {
    case secretNumber:
        hasWon = true
    case ..<secretNumber:
        print("📈 Plus grand !")
    default:
        print("📉 Plus petit !")
    }
} while !hasWon

if hasWon {
    let essaiMot = attempts > 1 ? "essais" : "essai"
    print("\n🎉 Bravo ! Le nombre était bien \(secretNumber). Trouvé en \(attempts) \(essaiMot).")
}
