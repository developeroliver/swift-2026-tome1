public protocol TaskRepository: Sendable {
    func loadAll() async throws -> [TaskItem]
    func save(_ tasks: [TaskItem]) async throws
}

public enum TaskError: Error, Sendable, Equatable {
    case notFound
    case invalidURL
    case networkError(statusCode: Int)
    case decodingFailed
}
