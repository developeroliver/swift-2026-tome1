public actor TaskManager {
    private let repository: any TaskRepository
    private let importer: RemoteTaskImporter
    private var tasks: [TaskItem] = []

    public init(repository: any TaskRepository, importer: RemoteTaskImporter = RemoteTaskImporter()) {
        self.repository = repository
        self.importer = importer
    }

    public func load() async throws {
        tasks = try await repository.loadAll()
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

    public func toggle(idPrefix: String) async throws {
        let index = try index(matchingPrefix: idPrefix)
        tasks[index].isDone.toggle()
        try await persist()
    }

    public func remove(idPrefix: String) async throws {
        let index = try index(matchingPrefix: idPrefix)
        tasks.remove(at: index)
        try await persist()
    }

    @discardableResult
    public func importFromRemote(limit: Int) async throws -> Int {
        let imported = try await importer.fetchTasks(limit: limit)
        tasks.append(contentsOf: imported)
        try await persist()
        return imported.count
    }

    private func index(matchingPrefix prefix: String) throws -> Int {
        guard let index = tasks.firstIndex(where: { $0.id.uuidString.hasPrefix(prefix.uppercased()) }) else {
            throw TaskError.notFound
        }
        return index
    }

    private func persist() async throws {
        try await repository.save(tasks)
    }
}
