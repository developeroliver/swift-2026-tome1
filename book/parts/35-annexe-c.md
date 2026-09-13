## C. Solutions des exercices {#annexe-c}

Ces solutions sont volontairement concises — une façon correcte de résoudre chaque exercice, pas toujours la seule. Si votre solution diffère mais produit le bon résultat, c'est tout aussi valable.

**1.1** — `swift --version` affiche la version installée ; `swift hello.swift` compile et exécute directement le fichier, sans étape séparée.

**2.1**
```swift
let name = "Olivier"
let age = 30
print("\(name) is \(age) years old.")
```

**3.1**
```swift
let username = "ada"
var loginCount = 0
loginCount += 1
loginCount += 1
loginCount += 1
print("\(username) has logged in \(loginCount) times.")
```

**4.1**
```swift
let quantity = 3
let unitPrice = 2.5
let total = Double(quantity) * unitPrice
print(String(format: "%.2f", total))   // 7.50
```

**5.1**
```swift
let n1 = 12.0, n2 = 8.0, n3 = 15.0
let average = (n1 + n2 + n3) / 3
print(average >= 10 ? "Pass" : "Fail")
```

**6.1**
```swift
func season(for month: Int) -> String {
    switch month {
    case 12, 1, 2: return "Winter"
    case 3...5: return "Spring"
    case 6...8: return "Summer"
    default: return "Fall"
    }
}
```

**7.1**
```swift
var count = 10
while count >= 1 {
    print(count)
    count -= 1
}
print("Liftoff!")

for i in stride(from: 10, through: 1, by: -1) {
    print(i)
}
print("Liftoff!")
```

**8.1**
```swift
let words = ["one", "two", "three", "four", "five"]
print(words[0...2])
for i in stride(from: 0, to: words.count, by: 2) {
    print(words[i])
}
```

**9.1**
```swift
let numbers = [4, 8, 15, 16, 23, 42]
let sum = numbers.filter { $0 % 2 == 0 }.map { $0 * 10 }.reduce(0, +)
```

**10.1**
```swift
let classA: Set<String> = ["Ada", "Grace", "Alan"]
let classB: Set<String> = ["Grace", "Tim", "Ada"]
let both = classA.intersection(classB)              // {"Ada", "Grace"}
let onlyOne = classA.symmetricDifference(classB)      // {"Alan", "Tim"}
```

**11.1**
```swift
let words = ["a", "b", "a", "c", "b", "a"]
var counts: [String: Int] = [:]
for word in words {
    counts[word, default: 0] += 1
}
```

**12.1**
```swift
func divide(_ a: Int, by b: Int) -> (quotient: Int, remainder: Int) {
    (a / b, a % b)
}
let result = divide(17, by: 5)
print("quotient: \(result.quotient), remainder: \(result.remainder)")
```

**13.1**
```swift
func isEven(_ number: Int) -> Bool {
    number % 2 == 0
}
func describe(_ number: Int, unit: String = "item") -> String {
    "\(number) \(unit)s"
}
```

**14.1**
```swift
func average(_ numbers: Double...) -> Double {
    numbers.isEmpty ? 0 : numbers.reduce(0, +) / Double(numbers.count)
}
func incrementInPlace(_ value: inout Int, by amount: Int = 1) {
    value += amount
}
```

**15.1**
```swift
let words = ["swift", "is", "great"]
let sortedWords = words.sorted { $0.count < $1.count }

func makeGreeter(prefix: String) -> (String) -> String {
    { name in prefix + name }
}
print(makeGreeter(prefix: "Hello, ")("Ada"))   // Hello, Ada
```

**16.1**
```swift
var middleName: String?
print(middleName)          // nil
middleName = "Grace"
print(middleName)           // Optional("Grace")
```

**17.1**
```swift
func doubleIfPossible(_ text: String) -> Int? {
    if let number = Int(text) {
        return number * 2
    }
    return nil
}
print(doubleIfPossible("21") ?? -1)     // 42
print(doubleIfPossible("abc") ?? -1)      // -1
```

**18.1**
```swift
func computeTotal(from raw: [String: String]) {
    guard let priceText = raw["price"], let price = Double(priceText) else {
        print("Invalid price")
        return
    }
    guard let quantityText = raw["quantity"], let quantity = Int(quantityText) else {
        print("Invalid quantity")
        return
    }
    print("Total: \(price * Double(quantity))")
}
// Avec les données de l'énoncé, affiche : "Invalid quantity"
```

**19.1**
```swift
struct Rectangle {
    var width: Double
    var height: Double
    func area() -> Double { width * height }
    mutating func scale(by factor: Double) {
        width *= factor
        height *= factor
    }
}
var r1 = Rectangle(width: 2, height: 3)
var r2 = r1
r2.scale(by: 2)
print(r1.width, r2.width)   // 2.0 4.0 : r1 inchangé
```

**20.1**
```swift
enum PaymentMethod {
    case cash
    case card(last4Digits: String)
    case giftCard(code: String, balance: Double)
}
func summary(for method: PaymentMethod) -> String {
    switch method {
    case .cash: return "Paying with cash"
    case .card(let digits): return "Card ending in \(digits)"
    case .giftCard(let code, let balance): return "Gift card \(code) with $\(balance) left"
    }
}
```

**21.1**
```swift
enum SearchResult {
    case empty
    case found(results: [String])
    case error(message: String)
}
func display(_ result: SearchResult) {
    switch result {
    case .empty: print("No results found")
    case .found(let results): print("Found \(results.count) results")
    case .error(let message): print("Error: \(message)")
    }
}
```

**22.1**
```swift
class Counter {
    var count = 0
    func increment() { count += 1 }
}
let c1 = Counter()
let c2 = c1
c2.increment()
print(c1.count)   // 1 : même instance
```

**23.1**
```swift
class Shape {
    func area() -> Double { 0 }
}
final class Square: Shape {
    let side: Double
    init(side: Double) { self.side = side }
    override func area() -> Double { side * side }
}
```

**24.1**
```swift
class Person {
    let name: String
    init(name: String) { self.name = name }
}
class Employee: Person {
    let salary: Double
    init(name: String, salary: Double) {
        self.salary = salary
        super.init(name: name)
    }
    convenience init(name: String) {
        self.init(name: name, salary: 0)
    }
}
```

**25.1** — (a) `struct` : une valeur simple sans identité propre. (b) `class` : une seule instance partagée dans toute l'application. (c) `struct` : une valeur copiable, deux cartes identiques sont interchangeables. (d) `class` : un état partagé qui doit rester synchronisé partout où il est utilisé.

**26.1**
```swift
struct Report {
    lazy var summary: String = {
        print("Computing summary...")
        return "Report ready"
    }()
}
var report = Report()
print("Before access")
print(report.summary)   // "Computing summary..." s'affiche seulement ici
```

**27.1**
```swift
extension Rectangle {
    var perimeter: Double { 2 * (width + height) }
    var isSquare: Bool {
        get { width == height }
        set { if newValue { height = width } }
    }
}
```

**28.1**
```swift
struct Player {
    var lives: Int = 3 {
        didSet {
            if lives == 0 { print("Game over!") }
        }
    }
}
```

**29.1**
```swift
struct Product {
    static var totalProductsCreated = 0
    init() { Product.totalProductsCreated += 1 }
}
_ = Product(); _ = Product(); _ = Product()
print(Product.totalProductsCreated)   // 3
```

**30.1**
```swift
protocol Playable {
    func play() -> String
}
struct Song: Playable {
    func play() -> String { "Playing song" }
}
struct Podcast: Playable {
    func play() -> String { "Playing podcast" }
}
func startPlaying(_ item: Playable) {
    print(item.play())
}
```

**31.1**
```swift
extension Playable {
    func describe() -> String { "Now playing" }
}
```

**32.1**
```swift
protocol Flyable { func fly() }
protocol Swimmable { func swim() }
struct Duck: Flyable, Swimmable {
    func fly() { print("Flying") }
    func swim() { print("Swimming") }
}
func showOff(_ animal: Flyable & Swimmable) {
    animal.fly()
    animal.swim()
}
```

**33.1**
```swift
protocol Stack {
    associatedtype Element
    mutating func push(_ element: Element)
    mutating func pop() -> Element?
}
struct IntStack: Stack {
    private var items: [Int] = []
    mutating func push(_ element: Int) { items.append(element) }
    mutating func pop() -> Int? { items.popLast() }
}
```

**34.1**
```swift
extension String {
    var isPalindrome: Bool {
        self == String(self.reversed())
    }
}
```

**35.1**
```swift
func allEqual<T: Equatable>(_ values: [T]) -> Bool {
    guard let first = values.first else { return true }
    return values.allSatisfy { $0 == first }
}
```

**36.1**
```swift
func merge<K: Hashable, V>(_ first: [K: V], _ second: [K: V]) -> [K: V] {
    first.merging(second) { _, new in new }
}
```

**37.1**
```swift
enum DivisionError: Error {
    case divisionByZero
}
func divide(_ a: Int, by b: Int) throws -> Int {
    guard b != 0 else { throw DivisionError.divisionByZero }
    return a / b
}
do {
    print(try divide(10, by: 0))
} catch {
    print("Error: \(error)")
}
print(try divide(10, by: 2))   // 5
```

**38.1**
```swift
extension DivisionError {
    // ajouter le nouveau case à l'enum :
    // case resultTooLarge(value: Int)
}
func divide(_ a: Int, by b: Int) throws -> Int {
    guard b != 0 else { throw DivisionError.divisionByZero }
    let result = a / b
    guard result <= 1000 else { throw DivisionError.resultTooLarge(value: result) }
    return result
}
extension DivisionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .divisionByZero: return "Cannot divide by zero."
        case .resultTooLarge(let value): return "Result \(value) is too large."
        }
    }
}
```

**39.1**
```swift
class Session {
    deinit { print("Session ended") }
}
var s1: Session? = Session()
var s2 = s1
s1 = nil                // rien ne s'affiche encore : s2 retient l'instance
print("s1 is nil, s2 still holds it")
s2 = nil                  // "Session ended" s'affiche ici
```

**40.1**
```swift
class Owner {
    let name: String
    var pet: Pet?
    init(name: String) { self.name = name }
    deinit { print("\(name) (Owner) deallocated") }
}
class Pet {
    let name: String
    weak var owner: Owner?
    init(name: String) { self.name = name }
    deinit { print("\(name) (Pet) deallocated") }
}
```
Grâce à `weak`, les deux `deinit` s'affichent quel que soit l'ordre dans lequel `owner`/`pet` sont mis à `nil`.

**41.1** — Sans capture list, `onUpdate` capture `self` fortement : `ViewModel` n'est jamais libéré (aucun message `deinit`). Avec `[weak self]` dans la closure et `guard let self else { return }`, le cycle est brisé et le message `deinit` apparaît dès que la dernière référence forte disparaît.

**42.1**
```swift
struct BankAccount {
    private var balance: Double = 0
    private func logTransaction(_ amount: Double) {
        print("Transaction: \(amount)")
    }
    mutating func deposit(_ amount: Double) {
        logTransaction(amount)
        balance += amount
    }
}
// account.logTransaction(10) depuis l'extérieur : ERREUR DE COMPILATION (private)
```

**43.1**
```swift
class Shape {}
class Circle: Shape {}
class Square: Shape {}
let shapes: [Shape] = [Circle(), Square(), Circle(), Circle()]
let circleCount = shapes.filter { $0 is Circle }.count   // 3
```

**44.1**
```swift
struct Square: Shape { var side: Double; func area() -> Double { side * side } }
func makeDefaultShape() -> some Shape {
    Circle(radius: 1)
}
```
Impossible de renvoyer tantôt `Circle`, tantôt `Square` : `some Shape` exige un seul type concret, fixe pour tous les appels de la fonction. Ce cas exige `any Shape` (chapitre 45).

**45.1**
```swift
let shapes: [any Shape] = [Circle(radius: 2), Square(side: 3), Circle(radius: 1)]
let totalArea = shapes.reduce(0) { $0 + $1.area() }
```

**46.1**
```swift
func typeName<T>(of value: T) -> String {
    String(describing: type(of: value))
}
print(typeName(of: 42))          // Int
print(typeName(of: "hello"))       // String
```

**47.1**
```swift
struct Product { let name: String; let price: Double }
let products = [Product(name: "A", price: 10), Product(name: "B", price: 20)]
let total = products.map(\.price).reduce(0, +)
```

**48.1**
```swift
@propertyWrapper
struct Capitalized {
    private var value: String = ""
    var wrappedValue: String {
        get { value }
        set { value = newValue.capitalized }
    }
    init(wrappedValue: String) { self.value = wrappedValue.capitalized }
}
struct Contact {
    @Capitalized var name: String
}
```

**49.1**
```swift
@propertyWrapper
struct Clamped {
    private var value: Int
    private let range: ClosedRange<Int>
    private(set) var clampCount = 0

    var wrappedValue: Int {
        get { value }
        set {
            let clamped = min(max(newValue, range.lowerBound), range.upperBound)
            if clamped != newValue { clampCount += 1 }
            value = clamped
        }
    }
    var projectedValue: Int { clampCount }

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}
```

**50.1**
```swift
@resultBuilder
struct IntSumBuilder {
    static func buildBlock(_ components: Int...) -> Int {
        components.reduce(0, +)
    }
    static func buildOptional(_ component: Int?) -> Int {
        component ?? 0
    }
}
```

**51.1**
```swift
func attr(_ name: String, _ value: String) -> String {
    "\(name)=\"\(value)\""
}
func link(href: String, @HTMLBuilder _ content: () -> String) -> String {
    "<a \(attr("href", href))>\(content())</a>"
}
// link(href: "https://swift.org") { text("Swift") }
// → <a href="https://swift.org">Swift</a>
```

**52.1** — Une race condition produit un résultat incorrect mais *défini* (par exemple, une incrémentation perdue). Une data race a un comportement *non défini* par le langage : crash, corruption silencieuse, ou succès apparent uniquement par chance. C'est cette absence totale de garantie qui la rend plus grave, et que Swift 6 cherche à éliminer à la compilation.

**53.1**
```swift
func waitAndReturn(_ value: Int) async -> Int {
    try? await Task.sleep(for: .seconds(1))
    return value
}
Task {
    let result = await waitAndReturn(42)
    print(result)
}
```

**54.1**
```swift
func fetchAllTodoCount(ids: [Int]) async throws -> Int {
    try await withThrowingTaskGroup(of: Todo.self) { group in
        for id in ids { group.addTask { try await fetchTodo(id: id) } }
        var count = 0
        for try await _ in group { count += 1 }
        return count
    }
}
```

**55.1**
```swift
func countdown() -> AsyncStream<Int> {
    AsyncStream { continuation in
        Task {
            for i in stride(from: 5, through: 1, by: -1) {
                try? await Task.sleep(for: .seconds(1))
                continuation.yield(i)
            }
            continuation.finish()
        }
    }
}
for await number in countdown() {
    print(number)
}
```

**56.1**
```swift
actor SafeCounter {
    var value = 0
    func increment() { value += 1 }
}
let counter = SafeCounter()
await withTaskGroup(of: Void.self) { group in
    for _ in 0..<10 {
        group.addTask {
            for _ in 0..<100 { await counter.increment() }
        }
    }
}
print(await counter.value)   // 1000, garanti par l'isolation de l'actor
```

**57.1** — Une `class` n'ayant qu'une seule property `let` (immuable) ne peut jamais être modifiée après sa création, par aucun thread : la « mutabilité potentiellement partagée » qui rend une `class` dangereuse par défaut est ici absente par construction. La déclarer `Sendable` manuellement documente cette garantie au compilateur.

**58.1** — Une macro s'exécute entièrement pendant la compilation, dans un programme séparé (le compiler plugin). Le code final ne contient que le résultat déjà expansé — aucune trace de la macro elle-même ne subsiste à l'exécution, donc aucun coût de performance possible à ce moment-là.

**59.1** — Exercice pratique : le texte affiché change pour refléter la nouvelle expression passée à `#stringify`, puisque `argument.description` capture le texte source exact de cette expression.

**60.1** — Exercice pratique de documentation, propre à votre code.

**Projet 6, exercice « pour aller plus loin »** — `git tag 1.0.0`, `git push --tags`, puis dans le nouveau package : `.package(url: "https://github.com/votre-compte/ValidatorKit.git", from: "1.0.0")` en dépendance, et `.product(name: "ValidatorKit", package: "ValidatorKit")` dans les dépendances du target.

**62.1**
```swift
assert(isEven(4))
assert(!isEven(3))
assert(isEven(0))
```

**63.1**
```swift
@Test("isEven works", arguments: [(2, true), (3, false), (4, true), (7, false)])
func isEvenWorks(number: Int, expected: Bool) {
    #expect(isEven(number) == expected)
}
```

**Projet 5, exercice « pour aller plus loin »** — `APIClient.send` dépend directement de `URLSession.shared`, impossible à substituer. Isoler un protocole `HTTPClient` avec une méthode `func data(from url: URL) async throws -> (Data, URLResponse)`, dont `URLSession` serait une implémentation, et un fake en mémoire une autre, rendrait `send` testable sans réseau — exactement le principe de `DataStore`.

**65.1** — Exercice pratique : le nom `square` apparaît dans le SIL généré, généralement précédé d'un préfixe de *mangling* du type `$s...6square...`.

**66.1**
```swift
// dans le "set" de Container.value :
if !isKnownUniquelyReferenced(&box) {
    print("Copying")
    box = Box(newValue)
}
var a = Container(1)
var b = a
var c = a
b.value = 2   // "Copying" s'affiche une seule fois : la première mutation partagée
```

**67.1** — Exercice de recherche personnelle sur le dépôt Swift Evolution.

**68.1** — La signature mélange un premier paramètre sans label (`_ validator: V`) et un deuxième aussi sans label (`_ value: V.Value`) suivi d'un label (`label:`) : à l'appel, `check(usernameValidator, "ab", label: "username")` ne se lit pas comme une phrase claire. Une meilleure version nommerait le second paramètre : `check(_ validator: V, validating value: V.Value, label: String)`, lue `check(usernameValidator, validating: "ab", label: "username")`.

**69.1** — Exercice de relecture personnelle des projets précédents.

**70, exercice final** — Exercice de relecture personnelle de vos propres projets.
