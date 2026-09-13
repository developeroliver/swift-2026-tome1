public actor InMemoryTaskRepository: TaskRepository {
    private var tasks: [TaskItem] = []

    public init(seed: [TaskItem] = []) {
        self.tasks = seed
    }

    public func loadAll() async throws -> [TaskItem] {
        tasks
    }

    public func save(_ tasks: [TaskItem]) async throws {
        self.tasks = tasks
    }
}
