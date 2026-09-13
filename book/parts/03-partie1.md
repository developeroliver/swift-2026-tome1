# Partie 1 — Découvrir Swift {#partie-1}

## 1. Introduction à Swift {#chap-1}

### Qu'est-ce que Swift ?

Swift est un langage de programmation créé par Apple, dévoilé en 2014 et passé open-source en 2015. Il a été conçu par une équipe menée par Chris Lattner pour remplacer progressivement Objective-C, le langage historique d'Apple, en corrigeant ses défauts (syntaxe verbeuse, absence de sécurité mémoire par défaut, gestion d'erreurs fragile) tout en restant interopérable avec lui.

Aujourd'hui, Swift dépasse largement le seul écosystème Apple : il tourne nativement sur **Linux** et **Windows**, sert à écrire des serveurs (avec des frameworks comme Vapor — voir le Tome 3 de cette collection), des outils en ligne de commande, et même du code embarqué. C'est ce langage généraliste, indépendant de toute UI, que ce tome explore en profondeur.

### Philosophie du langage

Swift a été conçu autour de quelques principes qui reviendront constamment dans ce livre :

- **Sécurité (safety)** — le compilateur vous empêche par construction d'écrire des catégories entières de bugs : accès à une variable non initialisée, utilisation d'une valeur `nil` non vérifiée, dépassement de tableau silencieux. Swift préfère qu'un programme refuse de compiler plutôt qu'il plante en production.
- **Clarté (clarity)** — le code Swift privilégie la lisibilité à la concision à tout prix. Une ligne de code doit se comprendre sans deviner ce qu'elle fait.
- **Performance** — Swift est compilé en code machine natif (via LLVM), pas interprété. Bien écrit, du Swift rivalise avec du C en performance.
- **Modernité progressive** — le langage évolue par un processus public et transparent, *Swift Evolution* (voir chapitre 67), ce qui lui permet d'intégrer rapidement des idées modernes (concurrence structurée, macros...) sans casser la compatibilité existante.

### Swift moderne

Le Swift de 2026 n'est plus le Swift de 2014. Ce livre couvre le langage **actuel**, notamment :

- la concurrence structurée avec `async`/`await` et les `actor` (Partie 16),
- le mode de concurrence stricte avec `Sendable`,
- les macros (Partie 17), qui permettent de générer du code à la compilation,
- Swift Testing, le framework de tests moderne (Partie 19).

Ces fonctionnalités n'existaient pas dans les premières versions du langage — gardez cela en tête si vous consultez d'anciennes ressources en ligne : du code Swift de 2015 peut sembler être un langage différent.

### Compilation

Contrairement à un langage interprété comme Python ou JavaScript, Swift est **compilé** : le code source (fichiers `.swift`) est transformé par le compilateur (`swiftc`, basé sur LLVM) en code machine exécutable directement par le processeur, *avant* l'exécution.

```text
Fichiers .swift  →  swiftc (compilateur)  →  exécutable binaire  →  exécution
```

Cela a deux conséquences immédiates et importantes :

1. Une grande partie des erreurs (types incompatibles, variable inexistante, fonction mal appelée) sont détectées **avant** que le programme tourne, à la compilation.
2. Un programme compilé démarre et s'exécute plus vite qu'un programme interprété, au prix d'une étape de compilation avant de pouvoir le lancer.

Vous pouvez aussi exécuter un fichier Swift directement avec la commande `swift`, qui compile puis lance immédiatement le résultat — pratique pour tester rapidement du code, moins adapté à un vrai projet.

### Swift Package Manager

**Swift Package Manager** (SPM) est l'outil officiel de gestion de projets et de dépendances Swift, intégré à la toolchain. C'est lui que ce livre utilise pour structurer le code des chapitres et des projets (détails complets en Partie 18).

Créer un nouveau projet exécutable :

```bash
mkdir HelloSwift
cd HelloSwift
swift package init --type executable
```

Cette commande génère une arborescence standard :

```text
HelloSwift/
├── Package.swift          <- décrit le projet et ses dépendances
├── Sources/
│   └── HelloSwift/
│       └── HelloSwift.swift
└── Tests/
    └── HelloSwiftTests/
```

Compiler et exécuter :

```bash
swift run
```

### Xcode / Swift Playground

Sur macOS, **Xcode** reste l'environnement le plus complet : autocomplétion avancée, débogueur visuel, et création de projets SPM en quelques clics (`File > New > Package`). **Swift Playgrounds** offre un environnement plus léger, pensé pour l'expérimentation immédiate : chaque ligne s'exécute au fur et à mesure que vous tapez, avec affichage des valeurs en temps réel dans une barre latérale — très utile pour les premiers chapitres de ce livre.

### Premier programme Swift

La tradition veut qu'on commence par afficher un message à l'écran :

```swift
print("Bonjour, Swift !")
```

C'est un programme Swift complet et valide. Une seule ligne suffit — il n'y a pas de fonction `main()` obligatoire, pas de classe à déclarer, pas de point d'entrée à définir explicitement dans un simple fichier exécutable. C'est un choix délibéré de Swift pour rester accessible aux débutants tout en restant un langage sérieux pour les experts.

<div class="exercise">
<div class="exercise-title">Exercice 1.1</div>
Installez Swift (toolchain officielle ou Xcode), vérifiez la version installée avec <code>swift --version</code>, puis créez un fichier <code>bonjour.swift</code> qui affiche votre prénom avec <code>print()</code>. Exécutez-le avec <code>swift bonjour.swift</code>.
</div>

## 2. Syntaxe de base {#chap-2}

### Commentaires

Swift propose trois formes de commentaires, ignorés par le compilateur :

```swift
// Commentaire sur une seule ligne

/* Commentaire
   sur plusieurs lignes */

/// Commentaire de documentation (triple-slash)
/// Décrit une fonction, un type, etc. Reconnu par Xcode
/// pour générer une aide contextuelle (Quick Help).
func direBonjour() {
    print("Bonjour")
}
```

Les commentaires `///` (ou `/** ... */`) ne sont pas de simples annotations : Xcode et les outils Swift les analysent pour afficher une documentation structurée (description, paramètres, valeur de retour) quand vous consultez une fonction.

### Instructions et blocs de code

En Swift, chaque instruction (*statement*) tient généralement sur une ligne, et **le point-virgule final est optionnel** :

```swift
let a = 1
let b = 2
print(a + b)
```

Vous *pouvez* mettre des points-virgules, notamment pour séparer plusieurs instructions sur une même ligne :

```swift
let a = 1; let b = 2; print(a + b)
```

Mais l'usage idiomatique (« Swifty ») est de ne jamais les utiliser en fin de ligne — le compilateur n'en a pas besoin.

Un **bloc de code** est délimité par des accolades `{ }`. On en trouve dans les fonctions, les conditions, les boucles, les types :

```swift
func exemple() {
    // ceci est un bloc de code
    print("À l'intérieur du bloc")
}
```

> **Piège courant** — contrairement à Python, l'indentation n'a **aucune signification syntaxique** en Swift : ce sont uniquement les accolades `{ }` qui délimitent un bloc. Une indentation cohérente reste indispensable pour la lisibilité, mais le compilateur l'ignore totalement.

### Identifiants

Un identifiant est le nom que vous donnez à une variable, une fonction, un type... Les règles :

- Il peut contenir des lettres, des chiffres, et le underscore `_`, mais ne peut pas **commencer** par un chiffre.
- Swift autorise même les caractères Unicode dans les identifiants : `let café = "espresso"` est valide (à utiliser avec parcimonie).
- Les mots réservés du langage (`let`, `var`, `func`, `struct`...) ne peuvent pas être utilisés tels quels comme identifiants — sauf si on les entoure de backticks : `` let `class` = "exception" `` est légal mais fortement déconseillé.

### Conventions Swift

Le langage a des conventions de nommage fortes, respectées par toute la communauté et par les API d'Apple elles-mêmes :

| Élément | Convention | Exemple |
|---|---|---|
| Variables, constantes, fonctions | `camelCase` | `let nombreDeJoueurs`, `func calculerScore()` |
| Types (struct, class, enum, protocol) | `PascalCase` | `struct Utilisateur`, `enum Direction` |
| Constantes globales | `camelCase` (pas de `UPPER_CASE`) | `let vitesseLumiere = 299_792_458` |

Ces conventions ne sont pas de simples préférences stylistiques : les respecter rend immédiatement votre code Swift lisible par n'importe quel autre développeur Swift, et c'est un prérequis pour le chapitre 68 (API Design Guidelines).

### `print()`

`print()` est la fonction de base pour afficher du texte dans la console. Elle accepte plusieurs arguments et des paramètres nommés utiles :

```swift
print("Swift")                          // Swift
print("Swift", "2026")                  // Swift 2026 (séparés par un espace)
print("Swift", "2026", separator: " - ") // Swift - 2026
print("Pas de retour à la ligne", terminator: "")
print(" — suite sur la même ligne")
```

On peut interpoler des valeurs directement dans une chaîne avec `\( )` :

```swift
let langage = "Swift"
let annee = 2026
print("\(langage) \(annee)")   // Swift 2026
print("2 + 2 = \(2 + 2)")      // 2 + 2 = 4
```

L'interpolation de chaînes sera revue en détail au chapitre 4 avec le type `String`.

<div class="exercise">
<div class="exercise-title">Exercice 2.1</div>
Écrivez un programme qui déclare deux constantes <code>prenom</code> et <code>age</code>, puis affiche une seule phrase les utilisant toutes les deux via l'interpolation de chaînes, par exemple : <code>"Olivier a 30 ans."</code>
</div>
