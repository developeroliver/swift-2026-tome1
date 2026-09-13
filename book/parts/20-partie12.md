# Partie 12 — Mémoire {#partie-12}

## 39. ARC {#chap-39}

### Automatic Reference Counting

Swift gère automatiquement la mémoire des `class` (les `struct` et `enum`, en tant que value types, n'ont pas besoin de ce mécanisme — voir chapitre 25) grâce à l'**ARC** (*Automatic Reference Counting*) : chaque instance de classe garde un compteur du nombre de références actives qui pointent vers elle. Quand ce compteur atteint zéro, la mémoire est libérée immédiatement — pas de ramasse-miettes (*garbage collector*) qui passe périodiquement, comme dans Java ou Python : la libération est déterministe et instantanée.

```swift
class Person {
    let name: String
    init(name: String) {
        self.name = name
        print("\(name) is being initialized")
    }
    deinit {
        print("\(name) is being deallocated")
    }
}

var person1: Person? = Person(name: "Ada")   // compteur de références : 1
person1 = nil                                    // compteur : 0 → deinit appelé immédiatement
// Ada is being initialized
// Ada is being deallocated
```

`deinit` est l'inverse d'`init` : un bloc de code exécuté juste avant que la mémoire de l'instance soit libérée — utile pour fermer une connexion, sauvegarder un état, ou simplement observer le cycle de vie comme ci-dessus.

### Strong references

Par défaut, **toute** référence à une instance de classe est une *strong reference* : elle incrémente le compteur de l'ARC et empêche la libération de la mémoire tant qu'elle existe :

```swift
var person2: Person? = Person(name: "Grace")   // compteur : 1
var person3 = person2                              // compteur : 2 (une deuxième strong reference)

person2 = nil        // compteur : 1 — toujours vivant, person3 le retient encore
person3 = nil          // compteur : 0 → deinit appelé maintenant
```

C'est ce comportement, parfaitement adapté à l'immense majorité des cas, qui peut devenir problématique dans une situation précise : deux instances qui se retiennent **mutuellement**, chacune empêchant l'autre d'atteindre zéro — le sujet du chapitre 41.

<div class="exercise">
<div class="exercise-title">Exercice 39.1</div>
Créez une classe <code>Session</code> avec un <code>deinit</code> qui affiche <code>"Session ended"</code>. Créez une instance dans une variable optionnelle, assignez-la à une seconde variable, mettez la première à <code>nil</code> et observez que <code>deinit</code> ne s'exécute pas encore. Mettez ensuite la seconde à <code>nil</code> et observez le message.
</div>

## 40. Weak & Unowned {#chap-40}

### `weak`

Une référence `weak` pointe vers une instance **sans** incrémenter son compteur ARC — elle n'empêche jamais la libération de la mémoire. Une conséquence directe : une référence `weak` doit obligatoirement être un **Optionnel** (`Partie 5`), puisque l'instance qu'elle désigne peut disparaître à tout moment, la laissant automatiquement à `nil` :

```swift
class Owner {
    let name: String
    var pet: Pet?
    init(name: String) { self.name = name }
}

class Pet {
    let name: String
    weak var owner: Owner?     // weak : ne retient pas Owner
    init(name: String) { self.name = name }
}

var owner: Owner? = Owner(name: "Ada")
var pet: Pet? = Pet(name: "Rex")

owner!.pet = pet
pet!.owner = owner

owner = nil            // Owner peut être libéré : pet.owner ne le retenait pas
print(pet!.owner)        // nil : la référence weak a été automatiquement remise à nil
```

### `unowned`

`unowned` ressemble à `weak` — elle ne retient pas non plus l'instance — mais avec deux différences importantes : elle n'est **pas** optionnelle, et elle suppose que l'instance référencée **survivra toujours au moins aussi longtemps** que celle qui la référence. Si cette hypothèse est fausse, accéder à une référence `unowned` dont la cible a été libérée provoque un **crash immédiat** :

```swift
class Customer {
    let name: String
    var card: CreditCard?
    init(name: String) { self.name = name }
}

class CreditCard {
    let number: String
    unowned let customer: Customer     // un CreditCard n'existe jamais sans son Customer
    init(number: String, customer: Customer) {
        self.number = number
        self.customer = customer
    }
}

let customer = Customer(name: "Ada")
customer.card = CreditCard(number: "1234", customer: customer)
print(customer.card!.customer.name)   // Ada
```

### Quand utiliser lequel

| | `weak` | `unowned` |
|---|---|---|
| Type | Toujours Optionnel (`Type?`) | Non optionnel (`Type`) |
| Si la cible est libérée | Devient automatiquement `nil` | Crash à l'accès suivant |
| À utiliser quand... | La cible **peut** légitimement disparaître avant la référence (ex : un délégué, un parent optionnel) | La cible **ne peut pas** disparaître avant la référence, par construction du programme (ex : une carte de crédit et son titulaire) |

> **Piège courant** — choisir `unowned` par réflexe pour éviter la gestion d'Optionnel qu'impose `weak` est une source classique de crash en production, souvent bien après l'écriture du code (quand une modification ultérieure change la durée de vie relative des deux objets). En cas de doute, `weak` est le choix le plus sûr — le coût d'un Optionnel supplémentaire est largement préférable au risque d'un crash.

<div class="exercise">
<div class="exercise-title">Exercice 40.1</div>
Reprenez l'exemple <code>Owner</code>/<code>Pet</code> et ajoutez un <code>deinit</code> à chacune des deux classes affichant un message. Vérifiez, en mettant les variables à <code>nil</code> dans différents ordres, que les deux instances sont bien libérées sans fuite mémoire.
</div>

## 41. Retain Cycles {#chap-41}

### Le problème : deux classes qui se retiennent mutuellement

Un *retain cycle* (ou *cycle de rétention*) survient quand deux instances se tiennent l'une l'autre par des **strong references**, chacune empêchant l'autre d'atteindre un compteur ARC de zéro — la mémoire de aucune des deux n'est jamais libérée, même quand plus rien d'autre dans le programme ne les référence :

```swift
class Owner {
    let name: String
    var pet: Pet?              // strong reference vers Pet
    init(name: String) { self.name = name }
    deinit { print("\(name) (Owner) deallocated") }
}

class Pet {
    let name: String
    var owner: Owner?          // strong reference vers Owner — PROBLÈME
    init(name: String) { self.name = name }
    deinit { print("\(name) (Pet) deallocated") }
}

var owner: Owner? = Owner(name: "Ada")
var pet: Pet? = Pet(name: "Rex")
owner!.pet = pet
pet!.owner = owner

owner = nil
pet = nil
// Aucun message "deallocated" ne s'affiche : fuite mémoire !
```

Même après avoir mis `owner` et `pet` à `nil`, chaque instance garde un compteur ARC de 1 — retenue par l'autre. C'est exactement le problème que `weak` (chapitre 40) est fait pour résoudre : reprendre cet exemple avec `weak var owner: Owner?` dans `Pet` (comme au chapitre précédent) brise le cycle, puisque `Pet` ne retient alors plus `Owner`.

### Retain cycles avec les closures

Une closure (chapitre 15) **capture** les variables de son environnement — et si elle capture `self` (par exemple pour appeler une méthode de l'instance courante) et qu'elle est elle-même stockée comme property de cette instance, un cycle apparaît de la même façon :

```swift
class ViewModel {
    var onUpdate: (() -> Void)?
    var data = "Initial"

    func setup() {
        onUpdate = {
            print("Data is now: \(self.data)")   // self capturé fortement par la closure
        }
    }

    deinit {
        print("ViewModel deallocated")
    }
}

var viewModel: ViewModel? = ViewModel()
viewModel!.setup()
viewModel = nil
// Rien ne s'affiche : ViewModel n'est jamais libéré
```

`onUpdate` est une property de `ViewModel`, et la closure qu'elle contient capture `self` (donc `ViewModel`) fortement — `ViewModel` retient `onUpdate`, qui retient `ViewModel` : le même cycle qu'entre deux classes, mais entre une instance et sa propre closure.

### Capture lists

Une *capture list*, entre crochets juste après l'ouverture de la closure, précise explicitement comment chaque variable doit être capturée :

```swift
class ViewModel {
    var onUpdate: (() -> Void)?
    var data = "Initial"

    func setup() {
        onUpdate = { [weak self] in
            guard let self else { return }
            print("Data is now: \(self.data)")
        }
    }

    deinit {
        print("ViewModel deallocated")
    }
}

var viewModel: ViewModel? = ViewModel()
viewModel!.setup()
viewModel = nil
// ViewModel deallocated
```

`[weak self]` capture `self` faiblement : la closure n'empêche plus `ViewModel` d'être libéré. `guard let self else { return }` (la forme courte du chapitre 17) transforme le `self` optionnel faible en une version non optionnelle utilisable pour le reste du bloc — si `self` a déjà été libéré au moment où la closure s'exécute, elle s'arrête simplement là, sans crash.

`[unowned self]` est aussi possible dans la capture list, avec exactement le même compromis qu'au chapitre 40 : plus simple (pas d'Optionnel à gérer), mais un crash si la closure s'exécute après que `self` a été libéré.

> **Règle pratique** — toute closure stockée comme property (ou capturée sur le long terme, par exemple passée à un système de notification ou de callback réseau comme au Projet 5) et qui utilise `self` mérite qu'on se pose la question du cycle de rétention. Une closure purement locale, utilisée immédiatement puis jetée (comme dans un `map` ou un `filter`), n'a jamais ce problème : elle ne survit pas assez longtemps pour retenir quoi que ce soit durablement.

<div class="exercise">
<div class="exercise-title">Exercice 41.1</div>
Reproduisez l'exemple <code>ViewModel</code> sans capture list, vérifiez (par l'absence du message <code>deinit</code>) que la fuite existe bien, puis corrigez-la avec <code>[weak self]</code> et vérifiez que le message apparaît désormais.
</div>
