import Foundation

public struct RemoteTaskImporter: Sendable {
    private struct RemoteTodo: Decodable {
        let title: String
        let completed: Bool
    }

    public init() {}

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

        let remoteTodos: [RemoteTodo]
        do {
            remoteTodos = try JSONDecoder().decode([RemoteTodo].self, from: data)
        } catch {
            throw TaskError.decodingFailed
        }

        return remoteTodos.map { remote in
            TaskItem(title: remote.title, isDone: remote.completed, priority: .medium)
        }
    }
}
