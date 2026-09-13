# Partie 14 — Property Wrappers {#partie-14}

## 48. Comprendre les Property Wrappers {#chap-48}

### Le problème : une logique répétée sur plusieurs properties

Imaginez vouloir garantir qu'une property numérique reste toujours dans un intervalle donné, en plusieurs endroits du code :

```swift
struct Character {
    private var _health: Int = 100
    var health: Int {
        get { _health }
        set { _health = min(max(newValue, 0), 100) }
    }
}
```

Cette logique (borner une valeur) devra être réécrite à l'identique pour chaque property qui en a besoin, dans chaque type — exactement le genre de duplication que Swift cherche systématiquement à éliminer.

### `@propertyWrapper`

Un *property wrapper* extrait cette logique dans un type réutilisable, appliqué ensuite comme une simple annotation :

```swift
@propertyWrapper
struct Clamped {
    private var value: Int
    private let range: ClosedRange<Int>

    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}
```

### `wrappedValue`

`wrappedValue` est le seul requirement réel d'un property wrapper : c'est la valeur exposée à l'usage, transparente pour qui l'utilise. L'annotation `@Clamped(...)` s'applique directement sur une déclaration de property :

```swift
struct Character {
    @Clamped(0...100) var health: Int = 100
}

var hero = Character()
hero.health = 150
print(hero.health)   // 100 : plafonné par le wrapper
hero.health = -20
print(hero.health)    // 0 : la même logique s'applique, sans la ré-écrire
```

Ce qui se passe réellement derrière cette syntaxe : `health` n'est **pas** un `Int` stocké directement — c'est une instance cachée de `Clamped`, et chaque lecture/écriture de `health` passe automatiquement par son `wrappedValue`. Vous avez déjà utilisé ce mécanisme sans le savoir si vous avez vu du code SwiftUI (`@State`, `@Binding` au Tome 2) : ce sont tous des property wrappers, construits exactement sur ce principe.

<div class="exercise">
<div class="exercise-title">Exercice 48.1</div>
Créez un property wrapper <code>@Capitalized</code> qui force une property <code>String</code> à toujours être stockée avec une majuscule initiale (indice : <code>.capitalized</code>). Appliquez-le à une property <code>name</code> d'une struct <code>Contact</code>.
</div>

## 49. Property Wrappers avancés {#chap-49}

### `projectedValue`

Un property wrapper peut exposer une **seconde** valeur, accessible avec le préfixe `$`, en plus de la valeur principale — c'est le `projectedValue` :

```swift
@propertyWrapper
struct Validated<Value> {
    private var value: Value
    private let rule: (Value) -> Bool

    var wrappedValue: Value {
        get { value }
        set { value = newValue }
    }

    var projectedValue: Bool {
        rule(value)
    }

    init(wrappedValue: Value, rule: @escaping (Value) -> Bool) {
        self.value = wrappedValue
        self.rule = rule
    }
}

struct SignupForm {
    @Validated(rule: { $0.contains("@") }) var email: String = ""
}

var form = SignupForm()
form.email = "not-an-email"
print(form.email)     // not-an-email : wrappedValue, la valeur elle-même
print(form.$email)      // false : projectedValue, ici un booléen de validité

form.email = "user@example.com"
print(form.$email)       // true
```

`form.email` accède au `wrappedValue` (la chaîne elle-même) ; `form.$email` accède au `projectedValue` (ici, un `Bool` indiquant si la règle de validation est respectée) — deux vues différentes de la même property sous-jacente, chacune utile dans un contexte différent.

### Créer des wrappers réutilisables et génériques

Le wrapper `Validated<Value>` ci-dessus est déjà générique (chapitre 35) : il fonctionne avec n'importe quel type, pas seulement `String`, tant qu'une règle de validation appropriée est fournie :

```swift
struct AgeForm {
    @Validated(rule: { $0 >= 18 }) var age: Int = 0
}

var ageForm = AgeForm()
ageForm.age = 15
print(ageForm.$age)   // false
ageForm.age = 25
print(ageForm.$age)    // true
```

### Un wrapper avec initializer personnalisé plus riche

Rien n'empêche un property wrapper d'accepter plusieurs paramètres de configuration à l'usage, au-delà de la seule valeur initiale :

```swift
@propertyWrapper
struct Logged<Value> {
    private var value: Value
    private let label: String

    var wrappedValue: Value {
        get { value }
        set {
            print("[\(label)] changed from \(value) to \(newValue)")
            value = newValue
        }
    }

    init(wrappedValue: Value, label: String) {
        self.value = wrappedValue
        self.label = label
        print("[\(label)] initialized with \(wrappedValue)")
    }
}

struct Thermostat {
    @Logged(label: "temperature") var temperature: Double = 20
}

var thermostat = Thermostat()
thermostat.temperature = 22
// [temperature] initialized with 20.0
// [temperature] changed from 20.0 to 22.0
```

> **Bonne pratique** — un property wrapper est un excellent outil pour une logique **transversale** (validation, bornage, journalisation, persistance automatique) qui s'appliquerait sinon de façon répétitive à travers de nombreuses properties. Pour une logique propre à un seul type et un seul endroit, une simple computed property (chapitre 27) reste plus directe et plus facile à suivre — n'introduisez un property wrapper que lorsque la réutilisation le justifie réellement.

<div class="exercise">
<div class="exercise-title">Exercice 49.1</div>
Ajoutez un <code>projectedValue: Int</code> au wrapper <code>Clamped</code> de l'exercice précédent, qui expose le nombre de fois où la valeur a été plafonnée (bornée par <code>range.lowerBound</code> ou <code>range.upperBound</code>) depuis sa création.
</div>
