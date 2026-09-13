# Partie 18 — Swift Package Manager {#partie-18}

## 60. Packages Swift {#chap-60}

### `Package.swift`

Chaque package Swift est décrit par un unique fichier `Package.swift`, à la racine du projet — vous en avez écrit plusieurs depuis le début du livre, sans forcément en détailler chaque partie :

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyLibrary",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "MyLibrary", targets: ["MyLibrary"])
    ],
    dependencies: [
        // des dépendances externes viendraient ici
    ],
    targets: [
        .target(name: "MyLibrary"),
        .testTarget(name: "MyLibraryTests", dependencies: ["MyLibrary"])
    ]
)
```

Le commentaire `// swift-tools-version: 6.0` en première ligne n'est **pas** un simple commentaire décoratif : Swift Package Manager le lit pour déterminer quelle version du langage `PackageDescription` utiliser pour interpréter le reste du fichier — c'est pourquoi le Projet 5 a pu fixer `5.10` pour éviter certains comportements de Swift 6.

### Products

Un *product* est ce qu'un package **expose** à l'extérieur — ce qu'un autre package peut effectivement importer et utiliser. Deux types principaux :

```swift
products: [
    .library(name: "MyLibrary", targets: ["MyLibrary"]),      // importable via "import MyLibrary"
    .executable(name: "MyCLI", targets: ["MyCLI"])                // un binaire exécutable
]
```

Un package peut définir zéro, un, ou plusieurs products — un projet purement applicatif (comme les Projets 1 à 4 de ce livre) n'a besoin d'aucun product explicite, seulement d'une cible exécutable.

### Targets

Un *target* est une unité de compilation — un module — avec son propre dossier de sources. Le Projet 6 a déjà illustré trois types de targets dans un même package :

```swift
targets: [
    .target(name: "ValidatorKit"),                                        // une bibliothèque
    .executableTarget(name: "ValidatorKitDemo", dependencies: ["ValidatorKit"]),  // un exécutable
    .testTarget(name: "ValidatorKitTests", dependencies: ["ValidatorKit"])        // des tests
]
```

Chaque target correspond par défaut à un dossier du même nom sous `Sources/` (ou `Tests/` pour un `.testTarget`) — c'est cette convention de nommage qui a organisé tous les projets de ce livre depuis le début.

### Dependencies

Un package peut dépendre d'autres packages, identifiés par leur URL Git et une contrainte de version :

```swift
dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
],
targets: [
    .target(
        name: "MyMacroImpl",
        dependencies: [
            .product(name: "SwiftSyntax", package: "swift-syntax")
        ]
    )
]
```

C'est exactement ce mécanisme qui a permis, au chapitre 59, d'utiliser `SwiftSyntax` pour construire une macro — une dépendance résolue et téléchargée automatiquement par `swift build`, sans gestionnaire de paquets externe à installer séparément (contrairement à npm pour JavaScript ou pip pour Python, tous deux extérieurs à leur langage).

<div class="exercise">
<div class="exercise-title">Exercice 60.1</div>
Reprenez l'un des projets précédents de ce livre (par exemple le Projet 4) et ajoutez, dans son <code>Package.swift</code>, un commentaire au-dessus de chaque section (<code>products</code>, <code>targets</code>) expliquant à quoi elle sert, en vous basant sur ce chapitre.
</div>

## 61. Créer une bibliothèque Swift {#chap-61}

### Package library : ce qui la distingue d'une application

Le Projet 6 (`ValidatorKit`) est déjà un exemple complet de bibliothèque Swift. Ce qui la qualifie de *bibliothèque* plutôt que de simple application, techniquement :

1. Un `product` de type `.library` dans `Package.swift`, rendant le module réellement importable depuis l'extérieur.
2. Des déclarations `public` (chapitre 42) pour tout ce qui doit être visible depuis un autre module — rappel du piège rencontré au Projet 6 : même l'initializer memberwise automatique d'une `struct` reste `internal` par défaut, et doit être explicitement rendu `public`.
3. Une API pensée pour être **stable** : une fois publiée et utilisée ailleurs, la modifier devient plus délicat (voir chapitre 68, API Design Guidelines).

### Organiser les tests

Une bibliothèque sérieuse s'accompagne toujours de tests (Partie 19, juste après) — le `.testTarget` du Projet 6 en est l'illustration minimale. `@testable import` (déjà vu au Projet 6) donne accès aux détails internes de la bibliothèque, indispensable pour tester des cas que l'API publique seule ne permettrait pas de vérifier directement.

### Organiser plusieurs modules

Une bibliothèque plus large se découpe souvent en plusieurs targets, chacun avec une responsabilité précise — un peu comme les fichiers séparés du Projet 6 (`Validator.swift`, `StringValidators.swift`, `RangeValidator.swift`), mais à l'échelle de modules entiers plutôt que de simples fichiers :

```swift
targets: [
    .target(name: "NetworkingCore"),                                     // primitives réseau bas niveau
    .target(name: "NetworkingJSON", dependencies: ["NetworkingCore"]),      // décodage JSON au-dessus
    .target(name: "Networking", dependencies: ["NetworkingCore", "NetworkingJSON"])  // API publique unifiée
]
```

Cette séparation permet à un consommateur du package de ne dépendre que de ce dont il a réellement besoin, et clarifie les responsabilités internes — chaque module a une seule raison de changer.

### Distribution

Publier une bibliothèque Swift pour que d'autres projets puissent la consommer se résume à :

1. Héberger le code dans un dépôt Git accessible (GitHub, GitLab, un serveur privé...).
2. Marquer des versions avec des tags Git suivant le *semantic versioning* (`1.0.0`, `1.1.0`, `2.0.0`...) — SwiftPM s'appuie directement sur ces tags pour résoudre les contraintes de version des dépendants.
3. S'assurer que `Package.swift` est valide à la racine du dépôt, avec les `products` correctement déclarés.

Un autre projet peut alors la consommer avec une simple ligne dans son propre `Package.swift` :

```swift
dependencies: [
    .package(url: "https://github.com/votre-compte/ValidatorKit.git", from: "1.0.0")
]
```

Aucune inscription sur un registre central n'est nécessaire (contrairement à npm ou crates.io) — l'URL Git **est** l'identifiant du package. C'est exactement ainsi que la dépendance à `swift-syntax` a fonctionné au chapitre précédent, et ainsi que fonctionnera toute dépendance tierce que vous ajouterez à un projet Swift, y compris au Tome 3 (Vapor lui-même est distribué comme un package Swift ordinaire).

<div class="exercise">
<div class="exercise-title">Exercice — pour aller plus loin</div>
Poussez le Projet 6 (<code>ValidatorKit</code>) vers un dépôt GitHub personnel, taguez un premier commit <code>1.0.0</code>, puis créez un tout nouveau package exécutable qui le déclare comme dépendance externe (avec l'URL de votre dépôt) et importe <code>ValidatorKit</code> pour valider une chaîne de caractères.
</div>
