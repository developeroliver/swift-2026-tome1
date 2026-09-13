import Foundation

public struct FileTaskRepository: TaskRepository {
    private let path: String

    public init(path: String) {
        self.path = path
    }

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
