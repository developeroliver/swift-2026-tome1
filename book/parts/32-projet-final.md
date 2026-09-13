# Projet final — 🚀 Swift Task Manager {#projet-final}

Ce projet rassemble, dans une seule application, la quasi-totalité des concepts de ce Tome 1 : protocoles, generics, `async`/`await`, actors, `Sendable`, gestion d'erreurs, `Codable`, réseau, persistence, dependency injection, tests, et Swift Package Manager. C'est intentionnellement le projet le plus long du livre — un point d'arrivée, pas un nouveau point de départ.

Le code complet se trouve dans `projects/08-swift-task-manager/` du dépôt GitHub.

### Architecture générale

```text
SwiftTaskManager/
├── Sources/
│   ├── TaskManagerCore/          <- bibliothèque : toute la logique métier
│   │   ├── Models/                  TaskItem
│   │   ├── Domain/                    TaskRepository (protocole), TaskManager (actor)
│   │   ├── Networking/                   RemoteTaskImporter
│   │   └── Persistence/                    FileTaskRepository, InMemoryTaskRepository
│   └── TaskManagerCLI/              <- exécutable : l'interface en ligne de commande
└── Tests/
    └── TaskManagerCoreTests/          <- tests de TaskManager, via InMemoryTaskRepository
```

Cette organisation en dossiers, à l'intérieur d'un seul target `TaskManagerCore` (chapitre 61), sépare les responsabilités sans complexité excessive — chaque dossier pourrait devenir son propre target si le projet grossissait encore, sans rien changer au code lui-même.

> **Piège courant** — le modèle central de ce projet s'appelle `TaskItem`, et non `Task`. Ce choix n'est pas arbitraire : Swift possède déjà un type `Task` dans sa bibliothèque de concurrence (chapitre 53, `Task { ... }`). Nommer son propre type `Task` dans le même module créerait une collision de noms — toute référence à `Task` dans ce fichier redeviendrait ambiguë entre les deux. Choisir un nom de domaine légèrement plus spécifique (`TaskItem`, `TaskEntry`...) évite ce genre de conflit avec la bibliothèque standard, un réflexe à garder pour tout futur projet.

### Le modèle

```swift
public struct TaskItem: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var isDone: Bool
    public var priority: Priority

    public enum Priority: String, Codable, Sendable, CaseIterable, Comparable {
        case low, medium, high

        private var rank: Int {
            switch self {
            case .low: 0
            case .medium: 1
            case .high: 2
            }
        }

        public static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rank < rhs.rank
        }
    }
}
```

`Codable` (utilisé ici pour la première fois formellement) est la combinaison de `Encodable` et `Decodable` — deux protocoles qui permettent à `JSONEncoder`/`JSONDecoder` de convertir automatiquement une `struct` vers et depuis du JSON, sans code de sérialisation manuel à écrire, du moment que toutes ses properties sont elles-mêmes `Codable` (ce qui est déjà le cas de `UUID`, `String`, `Bool`, et de l'enum à raw value `Priority`). Comparez avec l'analyse JSON manuelle des Projets 5 et 7 (`JSONSerialization`, `as?` en cascade) : `Codable` est la version idiomatique et bien plus sûre de la même idée, rendue possible parce que la forme des données est connue à l'avance.

`Priority` implémente `Comparable` (chapitre 35) avec une expression `switch` directement retournée (sans `return` ni `case ... :` suivi d'une instruction séparée) — la syntaxe moderne de « switch comme expression », qui permet à `all()` plus bas de trier les tâches par priorité avec un simple `>`.

### Le protocole au centre de l'architecture

```swift
public protocol TaskRepository: Sendable {
    func loadAll() async throws -> [TaskItem]
    func save(_ tasks: [TaskItem]) async throws
}
```

Toute la logique métier de `TaskManager` dépend de ce protocole, jamais d'une implémentation concrète — exactement le principe d'inversion de dépendance du chapitre 32, désormais appliqué à une application entière plutôt qu'à un seul exemple isolé.

### L'actor central : `TaskManager`

```swift
public actor TaskManager {
    private let repository: any TaskRepository
    private let importer: RemoteTaskImporter
    private var tasks: [TaskItem] = []

    public init(repository: any TaskRepository, importer: RemoteTaskImporter = RemoteTaskImporter()) {
        self.repository = repository
        self.importer = importer
    }

    public func all() -> [TaskItem] {
        tasks.sorted { $0.priority > $1.priority }
    }

    @discardableResult
    public func add(title: String, priority: TaskItem.Priority) async throws -> TaskItem {
        let task = TaskItem(title: title, priority: priority)
        tasks.append(task)
        try await persist()
        return task
    }

    private func persist() async throws {
        try await repository.save(tasks)
    }
}
```

`TaskManager` est un `actor` (chapitre 56), pas une simple `class` : l'application pourrait un jour appeler `add`, `toggle` et `remove` depuis plusieurs tâches concurrentes (par exemple, une future interface graphique au Tome 2, avec plusieurs actions déclenchées presque simultanément) — l'isolation de l'actor garantit qu'aucune de ces opérations ne pourra jamais corrompre `tasks`, exactement comme démontré au Projet 7. `any TaskRepository` (chapitre 45) accepte indifféremment `FileTaskRepository` ou `InMemoryTaskRepository`, selon ce qui est injecté à l'initialisation.

### Persistence réelle avec `Codable`

```swift
public struct FileTaskRepository: TaskRepository {
    private let path: String

    public func loadAll() async throws -> [TaskItem] {
        guard let data = FileManager.default.contents(atPath: path) else {
            return []
        }
        return try JSONDecoder().decode([TaskItem].self, from: data)
    }

    public func save(_ tasks: [TaskItem]) async throws {
        let data = try JSONEncoder().encode(tasks)
        FileManager.default.createFile(atPath: path, contents: data)
    }
}
```

Comparez avec le Projet 3 (Todo CLI), qui inventait son propre format texte ligne par ligne (`[x] texte`) : ici, `JSONEncoder`/`JSONDecoder` prennent en charge un format standard, structuré, et extensible — ajouter une nouvelle property à `TaskItem` ne demande aucune modification de `FileTaskRepository`.

### Réseau avec `Codable` : importer depuis une vraie API

```swift
public struct RemoteTaskImporter: Sendable {
    private struct RemoteTodo: Decodable {
        let title: String
        let completed: Bool
    }

    public func fetchTasks(limit: Int) async throws -> [TaskItem] {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos?_limit=\(limit)") else {
            throw TaskError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw TaskError.networkError(statusCode: statusCode)
        }

        let remoteTodos = try JSONDecoder().decode([RemoteTodo].self, from: data)
        return remoteTodos.map { TaskItem(title: $0.title, isDone: $0.completed, priority: .medium) }
    }
}
```

`RemoteTodo` est une `struct` **privée**, imbriquée dans `RemoteTaskImporter` : elle ne représente que la forme exacte du JSON distant, jamais exposée au reste de l'application, qui ne manipule que `TaskItem`. C'est la même idée d'isolation qu'un `Repository` (chapitre 69) : la forme des données externes ne doit jamais fuiter dans le modèle du domaine.

### Injection de dépendances et tests

```swift
@Test func tasksAreSortedByPriorityDescending() async throws {
    let repository = InMemoryTaskRepository()
    let manager = TaskManager(repository: repository)

    try await manager.add(title: "Low", priority: .low)
    try await manager.add(title: "High", priority: .high)
    try await manager.add(title: "Medium", priority: .medium)

    let titles = await manager.all().map(\.title)
    #expect(titles == ["High", "Medium", "Low"])
}

@Test func togglingAnUnknownIDThrows() async throws {
    let repository = InMemoryTaskRepository()
    let manager = TaskManager(repository: repository)

    await #expect(throws: TaskError.notFound) {
        try await manager.toggle(idPrefix: "ffffffff")
    }
}
```

Ces cinq tests (chapitre 64) s'exécutent en une fraction de seconde, sans jamais toucher au disque ni au réseau, grâce à `InMemoryTaskRepository` injecté à la place de `FileTaskRepository` — exactement le bénéfice de l'inversion de dépendance annoncé au début de ce chapitre, désormais vérifié en pratique sur l'application complète.

### Utiliser l'application

```bash
cd projects/08-swift-task-manager
swift run TaskManagerCLI
swift test
```

```text
> add high Write the final chapter
Added.
0011BD69 [ ] 🔴 Write the final chapter

> import 3
Imported 3 tasks from the remote API.

> list
0011BD69 [ ] 🔴 Write the final chapter
A44BD437 [ ] 🟡 delectus aut autem
...

> done 0011BD69
Updated.
```

Les tâches survivent d'une exécution à l'autre dans `tasks.json`, importées de l'API se mélangent naturellement à celles ajoutées manuellement, triées par priorité à chaque affichage.

<div class="exercise">
<div class="exercise-title">Exercice final</div>
Ajoutez une commande <code>filter &lt;low|medium|high&gt;</code> qui n'affiche que les tâches d'une priorité donnée, en réutilisant <code>manager.all()</code> et <code>filter</code> (chapitre 9) — sans modifier <code>TaskManager</code> lui-même, toute la logique doit tenir dans <code>TaskManagerCLI</code>. C'est l'occasion de vérifier que la séparation entre <code>TaskManagerCore</code> (la logique) et <code>TaskManagerCLI</code> (l'interface) fonctionne réellement : l'interface change, le cœur de l'application, non.
</div>

---

Ce projet clôt le Tome 1. Vous savez maintenant lire, écrire et tester du Swift moderne de bout en bout — sans avoir touché à une seule ligne d'interface graphique. C'est précisément ce qui vous attend au **Tome 2**, où l'application fil rouge de cette collection prend enfin un visage, avec SwiftUI.
