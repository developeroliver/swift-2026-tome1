## B. Aide-mémoire syntaxe {#annexe-b}

### Variables et types

```swift
let name = "Ada"              // constante, type inféré
var score: Int = 0               // variable, type annoté
let a, b, c: Double                // plusieurs constantes du même type
```

### Types de base

```swift
Int, UInt, Double, Float, Bool, String, Character
Int8, Int16, Int32, Int64 / UInt8, UInt16, UInt32, UInt64
```

### Opérateurs

```swift
+ - * / %                  // arithmétiques
== != > >= < <=              // comparaison
&& || !                        // logiques
+= -= *= /=                      // affectation composée
a ? b : c                          // ternaire
```

### Conditions

```swift
if condition { } else if condition { } else { }

switch value {
case pattern1, pattern2: ...
case let x where condition: ...
default: ...
}
```

### Boucles

```swift
for item in collection { }
for i in 0..<10 { }
for i in stride(from: 0, to: 10, by: 2) { }
while condition { }
repeat { } while condition
break / continue
label: while condition { break label }
```

### Fonctions et closures

```swift
func name(_ external: Type, label internal: Type = default) -> ReturnType { }

let closure: (Int) -> Int = { $0 * 2 }
array.map { $0 * 2 }                      // trailing closure
func f(_ completion: @escaping () -> Void) { }
```

### Optionnels

```swift
var x: Int?                              // déclaration
if let x { }                                // unwrap conditionnel
guard let x else { return }                    // unwrap ou sortie
x ?? defaultValue                                 // valeur par défaut
x?.property                                          // optional chaining
x!                                                     // force unwrap (à éviter)
```

### Collections

```swift
[1, 2, 3]                        // Array
Set([1, 2, 3])                     // Set
["key": "value"]                     // Dictionary
(1, "text")                            // Tuple

array.map { }, .filter { }, .reduce(initial) { }, .sorted(), .first, .contains()
```

### Struct / Class / Enum

```swift
struct Name {
    var property: Type
    func method() { }
    mutating func mutatingMethod() { }
}

class Name: Superclass {
    init() { }
    override func method() { }
}

enum Name {
    case simple
    case withValue(Type)
    case withRawValue = "raw"
}
```

### Properties

```swift
var computed: Type { get { } set { } }
var observed: Type { willSet { } didSet { } }
static var typeProperty: Type
lazy var lazyProperty: Type = expensiveInit()
```

### Protocoles et generics

```swift
protocol Name {
    associatedtype T
    var property: Type { get set }
    func method()
}

func generic<T: Constraint>(_ value: T) -> T { }
struct Box<T> { var value: T }

some Protocol      // type opaque, concret et fixe
any Protocole       // existential, type variable
```

### Gestion des erreurs

```swift
enum MyError: Error { case failure }
func f() throws { throw MyError.failure }
try f()
do { try f() } catch { print(error) }
try? f()      // vers Optional
try! f()       // crash si erreur
```

### Concurrence

```swift
func f() async -> Value { }
func f() async throws -> Value { }
await f()

Task { await f() }
async let x = f()
try await withThrowingTaskGroup(of: T.self) { group in }

actor Name { func method() { } }
@MainActor func onMainThread() { }
```

### Memory

```swift
weak var reference: Type?          // ne retient pas, devient nil
unowned let reference: Type          // ne retient pas, crash si accédée après libération
{ [weak self] in self?.method() }      // capture list
```

### Tests (Swift Testing)

```swift
import Testing

@Test func example() {
    #expect(condition)
}

@Test("Description", arguments: [1, 2, 3])
func parametrized(value: Int) { }

@Test func throwing() {
    #expect(throws: MyError.self) { try f() }
}
```
