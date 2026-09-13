# Annexes {#annexes}

## A. Glossaire Swift {#annexe-a}

**actor** — Type de référence dont l'état interne est protégé contre les accès concurrents simultanés par le compilateur (chapitre 56).

**ARC (Automatic Reference Counting)** — Mécanisme de gestion automatique de la mémoire des `class`, basé sur un comptage de références (chapitre 39).

**associated type** — Type générique déclaré à l'intérieur d'un protocole, rempli différemment par chaque type conforme (chapitre 33).

**async/await** — Syntaxe de concurrence structurée permettant d'écrire du code asynchrone avec une forme séquentielle (chapitre 53).

**closure** — Bloc de code autonome, sans nom, pouvant être stocké, passé en paramètre, et capturant les variables de son contexte (chapitre 15).

**Codable** — Combinaison de `Encodable` et `Decodable` ; permet la conversion automatique d'un type vers et depuis un format comme JSON (Projet final).

**compiler plugin** — Programme séparé, exécuté pendant la compilation, qui implémente l'expansion d'une macro (chapitre 59).

**computed property** — Property qui ne stocke rien, mais recalcule sa valeur à chaque accès (chapitre 27).

**Equatable** — Protocole exigeant l'implémentation de `==`, permettant de comparer deux valeurs (chapitre 34).

**escaping closure** — Closure passée en paramètre qui survit à la fonction qui l'a reçue, marquée `@escaping` (chapitre 15).

**existential** — Type effaçant l'identité concrète d'une valeur derrière un protocole, noté `any Protocole` (chapitre 45).

**extension** — Ajout de fonctionnalités (méthodes, computed properties, conformances) à un type déjà existant (chapitre 34).

**guard** — Instruction qui vérifie une condition et quitte immédiatement le contexte courant si elle échoue (chapitre 17).

**Hashable** — Protocole exigeant qu'une valeur puisse être hachée, requis pour les clés de `Dictionary` et les éléments d'un `Set` (chapitre 10).

**Identifiable** — Protocole standard exigeant une property `id`, permettant d'identifier chaque instance de façon unique.

**inout** — Modificateur de paramètre permettant à une fonction de modifier directement la variable passée en argument (chapitre 14).

**key path** — Référence non appelée vers une property, notée `\Type.property`, utilisable comme une donnée (chapitre 47).

**mutating** — Modificateur de méthode autorisant une `struct` ou un `enum` à modifier ses propres properties (chapitre 19).

**Optional** — Type représentant une valeur qui peut être absente (`nil`), noté `Type?` (Partie 5).

**property observer** — Bloc de code (`willSet`/`didSet`) exécuté autour d'un changement de valeur d'une stored property (chapitre 28).

**property wrapper** — Type réutilisable encapsulant une logique de lecture/écriture appliquée à une property via `@NomDuWrapper` (Partie 14).

**protocol** — Contrat définissant un ensemble de properties et de méthodes qu'un type conforme s'engage à fournir (chapitre 30).

**race condition** — Comportement incorrect résultant de l'ordre imprévisible d'exécution de plusieurs threads (chapitre 52).

**reference semantics** — Comportement des `class` : copier une variable copie une référence vers la même instance (chapitre 25).

**result builder** — Mécanisme transformant une séquence d'expressions en une valeur unique, base de SwiftUI (Partie 15).

**retain cycle** — Fuite mémoire causée par deux instances qui se retiennent mutuellement via des strong references (chapitre 41).

**Sendable** — Protocole certifiant qu'une valeur peut être partagée en toute sécurité entre plusieurs contextes concurrents (chapitre 57).

**stored property** — Property qui stocke réellement une valeur en mémoire (chapitre 26).

**strong reference** — Référence par défaut vers une instance de classe, qui incrémente son compteur ARC (chapitre 39).

**struct** — Type valeur regroupant properties et méthodes, avec un initializer memberwise automatique (chapitre 19).

**Swift Evolution** — Processus public de proposition et de décision qui fait évoluer le langage Swift (chapitre 67).

**Swift Package Manager (SPM)** — Outil officiel de gestion de projets et de dépendances Swift (chapitre 60).

**target** — Unité de compilation (module) au sein d'un package Swift (chapitre 60).

**TaskGroup** — Structure de concurrence gérant un nombre dynamique de tâches enfants en parallèle (chapitre 54).

**trailing closure** — Syntaxe permettant d'écrire la dernière closure d'un appel de fonction en dehors des parenthèses (chapitre 15).

**value semantics** — Comportement des `struct` et `enum` : copier une variable crée une copie totalement indépendante (chapitre 25).

**weak reference** — Référence qui ne retient pas son instance cible, automatiquement mise à `nil` si celle-ci est libérée (chapitre 40).
