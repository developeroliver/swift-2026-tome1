# Swift 2026 — Tome 1
## Maîtriser Swift de zéro à expert (sans SwiftUI, sans iOS)

> Public visé : aucune connaissance préalable de Swift requise. Objectif de sortie : niveau intermédiaire/avancé, prêt pour un Tome 2 dédié à SwiftUI.

---

### Avant-propos
- À qui s'adresse ce livre
- Comment l'utiliser (théorie + projets)
- Installer Swift (Xcode, toolchain officielle, Swift Playground)
- Conventions du livre (encadrés, exercices, code)

---

## PARTIE 1 — Découvrir Swift
1. **Introduction à Swift** — Qu'est-ce que Swift ? Philosophie du langage, Swift moderne, compilation, Swift Package Manager, Xcode/Swift Playground, premier programme
2. **Syntaxe de base** — Commentaires, instructions, blocs de code, identifiants, conventions Swift, `print()`

## PARTIE 2 — Les fondamentaux
3. **Variables et constantes** — `let`, `var`, mutabilité, inférence de type, annotation de type, type safety
4. **Types fondamentaux** — `Int`, `UInt`, `Double`, `Float`, `Bool`, `String`, `Character`
5. **Opérateurs** — arithmétiques, comparaison, logiques, affectation, composés, ternaire, opérateurs personnalisés
6. **Conditions** — `if`/`else`/`else if`, `switch`, pattern matching, `where`
7. **Boucles** — `for-in`, `while`, `repeat-while`, `break`, `continue`
8. **Ranges** — `...`, `..<`, ranges avec collections

**Projet 1 : 🎯 Jeu de devinettes**

## PARTIE 3 — Collections
9. **Arrays** — création, accès, modification, suppression, parcours, `map`/`filter`/`reduce`/`compactMap`/`flatMap`, `sorted`, `contains`, `first`/`last`
10. **Sets** — création, unicité, ajout/suppression, union, intersection, différence, recherche
11. **Dictionaries** — clés/valeurs, création, modification, suppression, parcours, recherche, `mapValues`
12. **Tuples** — création, décomposition, tuples nommés, quand les utiliser

**Projet 2 : 🧮 Calculatrice**

## PARTIE 4 — Fonctions
13. **Fonctions** — déclaration, paramètres, retour, paramètres externes, `_`, valeurs par défaut
14. **Fonctions avancées** — fonctions comme valeurs, fonctions retournant des fonctions, higher-order functions, `inout`, paramètres variadiques
15. **Closures** — syntaxe, paramètres, retour, trailing closures, shorthand arguments, capture de variables, `@escaping`, closures autocontenues

## PARTIE 5 — Optionnels
16. **Comprendre les Optionnels** — pourquoi `Optional` ?, `nil`, `String?`, `Int?`
17. **Manipuler les Optionnels** — `if let`, `guard let`, optional chaining, `??`, `!`, `as?`
18. **Optionnels avancés** — nested optionals, optional mapping, bonnes pratiques, éviter le force unwrap

**Projet 3 : ✅ Todo CLI**

## PARTIE 6 — Structures et énumérations
19. **Structures** — properties, methods, initializers, mutating methods, value semantics
20. **Enums** — cases, associated values, raw values, methods, properties, pattern matching
21. **Enums avancés** — enums récursifs, `indirect`, modéliser des états avec enums

## PARTIE 7 — Classes et références
22. **Classes** — création, properties, methods, initializers, reference semantics
23. **Héritage** — classes parent/enfant, `override`, `super`, `final`
24. **Initialisation** — initializer par défaut, personnalisé, failable, `required`, `convenience`, héritage d'initialisation
25. **Value vs Reference** — struct/class/enum, copying, mutations, références, copy-on-write

**Projet 4 : 💰 Expense Tracker**

## PARTIE 8 — Properties
26. **Stored Properties** — constantes, variables, `lazy`
27. **Computed Properties** — getters/setters calculés
28. **Property Observers** — `willSet`, `didSet`
29. **Type Properties** — `static`, `class`

## PARTIE 9 — Protocoles
30. **Protocoles** — déclaration, requirements, properties, methods
31. **Protocol Extensions** — implémentations par défaut
32. **Protocol-Oriented Programming** — composition, inversion de dépendance, protocoles vs héritage
33. **Associated Types** — `associatedtype`, contraintes, protocoles génériques

## PARTIE 10 — Extensions et génériques
34. **Extensions** — ajouter méthodes/properties, conformance à un protocole
35. **Generics** — fonctions génériques, types génériques, contraintes
36. **Generics avancés** — `where`, associated types, protocoles génériques, contraintes de type

**Projet 5 : 🌐 API Client**

## PARTIE 11 — Gestion des erreurs
37. **Error Handling** — `Error`, `throw`, `throws`, `try`, `do`/`catch`
38. **Gestion avancée des erreurs** — `try?`, `try!`, catches multiples, erreurs personnalisées, propagation

## PARTIE 12 — Mémoire
39. **ARC** — Automatic Reference Counting, strong references
40. **Weak & Unowned** — `weak`, `unowned`, quand les utiliser
41. **Retain Cycles** — classes, closures, capture lists

## PARTIE 13 — Swift avancé
42. **Access Control** — `private`, `fileprivate`, `internal`, `public`, `open`, `package`
43. **Type Casting** — `is`, `as`, `as?`, `as!`
44. **Opaque Types** — `some`, pourquoi `some` existe
45. **Existentials** — `any`, protocol existentials, `some` vs `any`
46. **Metatypes** — `Type`, `self`, `Self`
47. **Key Paths** — `\Type.property`, `KeyPath`, `WritableKeyPath`, `PartialKeyPath`

**Projet 6 : 📦 Swift Package (bibliothèque réutilisable)**

## PARTIE 14 — Property Wrappers
48. **Comprendre les Property Wrappers** — pourquoi, `@propertyWrapper`, `wrappedValue`
49. **Property Wrappers avancés** — `projectedValue`, créer des wrappers réutilisables

## PARTIE 15 — Result Builders
50. **Result Builders** — concept, `@resultBuilder`, `buildBlock`, `buildOptional`, `buildEither`
51. **Créer son propre DSL Swift** — result builders avancés

## PARTIE 16 — Concurrence moderne
52. **Comprendre la concurrence** — synchrone vs asynchrone, threads, race conditions, data races
53. **`async`/`await`** — fonctions async, `await`, `Task`
54. **Structured Concurrency** — hiérarchie de tâches, annulation, task groups
55. **`AsyncSequence`** — `for await`, flux asynchrones
56. **Actors** — `actor`, isolation, `MainActor`, réentrance
57. **Sendable** — `Sendable`, `@Sendable`, concurrence stricte, partage sûr de données

**Projet 7 : ⚡ Concurrent Data Engine**

## PARTIE 17 — Macros
58. **Introduction aux macros** — pourquoi, métaprogrammation à la compilation
59. **Macros Swift** — freestanding, attached, expansion, créer une macro

## PARTIE 18 — Swift Package Manager
60. **Packages Swift** — `Package.swift`, products, targets, dependencies
61. **Créer une bibliothèque Swift** — package library, tests, modules, distribution

## PARTIE 19 — Tests
62. **Tester du Swift** — pourquoi tester, unit testing, architecture de tests
63. **Swift Testing** — `@Test`, `#expect`, `#require`, tests async, tests paramétrés
64. **Tester une architecture** — dependency injection, mocks, stubs, fakes

## PARTIE 20 — Niveau expert
65. **Comprendre le compilateur Swift** — compilation, type checking, génération de code, modules
66. **Mémoire & performance** — stack, heap, allocation, copy-on-write, ARC, performance des collections
67. **Swift Evolution** — SE proposals, comment Swift évolue, lire une proposition
68. **API Design Guidelines** — naming, ergonomie d'API, concevoir des API réutilisables
69. **Patterns Swift** — Factory, Builder, Strategy, Repository, Dependency Injection, Observer, Result type
70. **Écrire du Swift idiomatique** — code lisible, sûr, performant, anti-patterns, l'approche "Swifty"

**Projet final : 🚀 Swift Task Manager** (protocoles, generics, async/await, actors, Sendable, erreurs, Codable, networking, persistence, DI, tests, SwiftPM)

---

### Annexes
- A. Glossaire Swift
- B. Aide-mémoire syntaxe (cheat sheet)
- C. Solutions des exercices
- D. Ressources pour aller plus loin (Swift Evolution, forums, documentation)
