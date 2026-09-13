# Partie 6 — Structures et énumérations {#partie-6}

## 19. Structures {#chap-19}

Properties, methods, initializers, mutating methods, value semantics.

## 20. Enums {#chap-20}

Cases, associated values, raw values, methods, properties, pattern matching.

## 21. Enums avancés {#chap-21}

Enum récursifs, `indirect`, états avec enums, modeling avec enums.

# Partie 7 — Classes et références {#partie-7}

## 22. Classes {#chap-22}

Création, properties, methods, initializers, reference semantics.

## 23. Héritage {#chap-23}

Parent / child classes, `override`, `super`, `final`.

## 24. Initialisation {#chap-24}

Default initializer, custom initializer, failable initializer, `required`, `convenience`, initialization inheritance.

## 25. Value vs Reference {#chap-25}

Struct → value semantics, Class → reference semantics, Enum → value semantics. Copying, mutations, références, copy-on-write.

# Projet 4 — 💰 Expense Tracker {#projet-4}

Modélisation avec struct/class/enum, calculs, catégorisation des dépenses.

# Partie 8 — Properties {#partie-8}

## 26. Stored Properties {#chap-26}

Constants, variables, lazy properties.

## 27. Computed Properties {#chap-27}

Properties calculées à la lecture.

## 28. Property Observers {#chap-28}

`willSet`, `didSet`.

## 29. Type Properties {#chap-29}

`static`, `class`.

# Partie 9 — Protocoles {#partie-9}

## 30. Protocoles {#chap-30}

Déclaration, requirements, properties, methods.

## 31. Protocol Extensions {#chap-31}

Default implementations, extensions.

## 32. Protocol-oriented programming {#chap-32}

Composition, dependency inversion, protocols vs inheritance.

## 33. Associated Types {#chap-33}

`associatedtype`, contraintes, protocoles génériques.

# Partie 10 — Extensions et génériques {#partie-10}

## 34. Extensions {#chap-34}

Ajouter des méthodes, ajouter des properties, conformer à un protocole.

## 35. Generics {#chap-35}

Generic functions, generic types, generic constraints.

## 36. Generics avancés {#chap-36}

`where`, associated types, generic protocols, type constraints.

# Projet 5 — 🌐 API Client {#projet-5}

Client réseau générique avec protocoles, generics et gestion d'erreurs.

# Partie 11 — Gestion des erreurs {#partie-11}

## 37. Error Handling {#chap-37}

`Error`, `throw`, `throws`, `try`, `do`, `catch`.

## 38. Gestion avancée {#chap-38}

`try?`, `try!`, multiple catches, custom errors, propagation des erreurs.

# Partie 12 — Mémoire {#partie-12}

## 39. ARC {#chap-39}

Automatic Reference Counting, strong references.

## 40. Weak & Unowned {#chap-40}

`weak`, `unowned`, quand les utiliser.

## 41. Retain Cycles {#chap-41}

Classes, closures, capture lists.

# Partie 13 — Swift avancé {#partie-13}

## 42. Access Control {#chap-42}

`private`, `fileprivate`, `internal`, `public`, `open`, `package`.

## 43. Type Casting {#chap-43}

`is`, `as`, `as?`, `as!`.

## 44. Opaque Types {#chap-44}

`some`, pourquoi `some` existe.

## 45. Existentials {#chap-45}

`any`, protocol existentials, `some` vs `any`.

## 46. Metatypes {#chap-46}

`Type`, `self`, `Self`.

## 47. Key Paths {#chap-47}

`\Type.property`, KeyPath, WritableKeyPath, PartialKeyPath.

# Projet 6 — 📦 Swift Package {#projet-6}

Création d'une bibliothèque Swift réutilisable et publiable.

# Partie 14 — Property Wrappers {#partie-14}

## 48. Comprendre les Property Wrappers {#chap-48}

Pourquoi ?, `@propertyWrapper`, `wrappedValue`.

## 49. Property Wrappers avancés {#chap-49}

`projectedValue`, `@Wrapper`, création de wrappers réutilisables.

# Partie 15 — Result Builders {#partie-15}

## 50. Result Builders {#chap-50}

Concept, `@resultBuilder`, `buildBlock`, `buildOptional`, `buildEither`.

## 51. Créer son propre DSL Swift {#chap-51}

DSL, result builders avancés.

# Partie 16 — Concurrence moderne {#partie-16}

## 52. Comprendre la concurrence {#chap-52}

Synchrone vs asynchrone, threads, race conditions, data races.

## 53. `async` / `await` {#chap-53}

Fonctions async, `await`, `Task`.

## 54. Structured Concurrency {#chap-54}

Task hierarchy, cancellation, task groups.

## 55. `AsyncSequence` {#chap-55}

`for await`, flux asynchrones.

## 56. Actors {#chap-56}

`actor`, isolation, `MainActor`, actor reentrancy.

## 57. Sendable {#chap-57}

`Sendable`, `@Sendable`, strict concurrency, safe data sharing.

# Projet 7 — ⚡ Concurrent Data Engine {#projet-7}

Moteur de traitement de données concurrent avec actors, task groups et Sendable.

# Partie 17 — Macros {#partie-17}

## 58. Introduction aux macros {#chap-58}

Pourquoi les macros ?, compile-time metaprogramming.

## 59. Macros Swift {#chap-59}

Freestanding macros, attached macros, expansion, création d'une macro.

# Partie 18 — Swift Package Manager {#partie-18}

## 60. Packages Swift {#chap-60}

`Package.swift`, products, targets, dependencies.

## 61. Créer une bibliothèque Swift {#chap-61}

Package library, tests, modules, distribution.

# Partie 19 — Tests {#partie-19}

## 62. Tester du Swift {#chap-62}

Pourquoi tester ?, unit testing, test architecture.

## 63. Swift Testing {#chap-63}

`@Test`, `#expect`, `#require`, tests async, parametrized tests.

## 64. Tester une architecture {#chap-64}

Dependency injection, mocks, stubs, fakes.

# Partie 20 — Niveau expert {#partie-20}

## 65. Comprendre le compilateur Swift {#chap-65}

Compilation, type checking, génération du code, modules.

## 66. Memory & performance {#chap-66}

Stack, heap, allocation, copy-on-write, ARC, performance des collections.

## 67. Swift Evolution {#chap-67}

SE proposals, comment Swift évolue, lire une proposition Swift Evolution.

## 68. API Design Guidelines {#chap-68}

Naming, API ergonomics, designing reusable APIs.

## 69. Patterns Swift {#chap-69}

Factory, Builder, Strategy, Repository, Dependency Injection, Observer, Result type.

## 70. Écrire du Swift idiomatique {#chap-70}

Code lisible, sûr, performant, éviter les anti-patterns, approche "Swifty".

# Projet final — 🚀 Swift Task Manager {#projet-final}

Application complète : protocoles, generics, async/await, actors, Sendable, erreurs, Codable, networking, persistence, dependency injection, tests, Swift Package Manager.

# Annexes {#annexes}

## A. Glossaire Swift {#annexe-a}

## B. Aide-mémoire syntaxe {#annexe-b}

## C. Solutions des exercices {#annexe-c}

## D. Ressources pour aller plus loin {#annexe-d}
