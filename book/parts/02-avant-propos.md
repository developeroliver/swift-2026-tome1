# Avant-propos {#avant-propos}

## À qui s'adresse ce livre

Ce livre s'adresse à toute personne qui ne connaît **pas encore Swift**, qu'elle vienne d'un autre langage (Python, JavaScript, Java, C#, Kotlin...) ou qu'elle découvre la programmation. Aucun prérequis Swift n'est nécessaire.

L'objectif est clair : à la fin de ce Tome 1, vous devez maîtriser le **langage Swift** à un niveau intermédiaire/avancé — suffisant pour lire n'importe quel code Swift open-source, contribuer à un projet, et aborder sereinement le Tome 2 (SwiftUI).

Ce livre ne parle **ni de SwiftUI, ni d'UIKit, ni d'iOS, ni d'aucun framework Apple**. C'est un choix assumé : mélanger l'apprentissage du langage et celui d'un framework d'interface graphique dilue la compréhension des deux. Ici, vous apprenez Swift *en tant que langage de programmation*, exécutable en ligne de commande, sur macOS comme sur Linux.

## Comment l'utiliser

Chaque partie du livre suit la même logique :

1. **Théorie** — un chapitre explique un concept avec des exemples de code commentés.
2. **Pièges courants** — encadrés qui signalent les erreurs classiques.
3. **Exercice** — un mini-exercice pour pratiquer immédiatement.
4. **Projet** — régulièrement, plusieurs chapitres se rassemblent dans un projet complet, avec le code source entier fourni et expliqué.

Le code de tous les projets est disponible dans le dépôt GitHub qui accompagne ce livre, dans le dossier `projects/`. Le code des exemples de chaque chapitre est dans `code/`.

> **Conseil** : ne vous contentez pas de lire le code des exemples — tapez-le et exécutez-le vous-même. C'est la seule façon de développer une véritable intuition du langage.

## Installer Swift

Trois façons d'exécuter du Swift, du plus simple au plus complet :

**Swift Playgrounds** (macOS / iPad) — une app graphique pour écrire et exécuter de petits bouts de Swift instantanément, sans configuration. Idéal pour les tout premiers chapitres.

**Xcode** (macOS uniquement) — l'IDE officiel d'Apple. Il inclut le compilateur Swift et permet de créer des projets en ligne de commande (`Command Line Tool`) aussi bien que des apps graphiques. C'est l'environnement recommandé pour suivre ce livre si vous êtes sur Mac.

**La toolchain Swift officielle** (macOS / Linux / Windows) — installable indépendamment d'Xcode depuis [swift.org](https://swift.org), elle fournit le compilateur `swiftc`, l'interpréteur `swift`, et Swift Package Manager (`swift build`, `swift run`, `swift test`). C'est ce qui a été utilisé pour écrire et tester tout le code de ce livre.

Vérifier que Swift est installé :

```bash
swift --version
```

Exécuter un fichier directement, sans compilation préalable :

```bash
swift chemin/vers/fichier.swift
```

Ou créer un projet exécutable complet avec Swift Package Manager (détaillé au chapitre 1) :

```bash
mkdir MyProject && cd MyProject
swift package init --type executable
swift run
```

## Conventions du livre

- Le code Swift est toujours présenté dans des blocs colorés comme celui-ci :

```swift
let message = "Welcome to Swift"
print(message)
```

- Les encadrés orangés signalent un **piège courant** ou une **subtilité importante** :

> **Piège courant** — un exemple de piège ressemblera à ceci, avec une explication de pourquoi le code se comporte différemment de ce qu'on pourrait attendre.

- Les encadrés verts marquent un **exercice** à faire vous-même avant de continuer :

<div class="exercise">
<div class="exercise-title">Exercice</div>
Un exercice ressemblera à ceci : un énoncé court, à résoudre avec les outils vus dans le chapitre. Les corrigés sont en Annexe C.
</div>

Bonne lecture, et surtout : bon code.
