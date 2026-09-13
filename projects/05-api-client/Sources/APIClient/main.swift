import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(String)
    case serverError(statusCode: Int)
    case invalidResponse
    case decodingFailed

    func describe() -> String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .serverError(let statusCode):
            return "Server error (status \(statusCode))"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed:
            return "Could not decode the response"
        }
    }
}

protocol APIRequest {
    associatedtype Response
    var url: URL? { get }
    func decode(_ data: Data) -> Result<Response, APIError>
}

struct Todo {
    let id: Int
    let title: String
    let isCompleted: Bool
}

struct FetchTodoRequest: APIRequest {
    let id: Int

    var url: URL? {
        URL(string: "https://jsonplaceholder.typicode.com/todos/\(id)")
    }

    func decode(_ data: Data) -> Result<Todo, APIError> {
        guard
            let raw = try? JSONSerialization.jsonObject(with: data),
            let json = raw as? [String: Any],
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let isCompleted = json["completed"] as? Bool
        else {
            return .failure(.decodingFailed)
        }
        return .success(Todo(id: id, title: title, isCompleted: isCompleted))
    }
}

struct APIClient {
    func send<Request: APIRequest>(
        _ request: Request,
        completion: @escaping (Result<Request.Response, APIError>) -> Void
    ) {
        guard let url = request.url else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(.requestFailed(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }

            guard let data else {
                completion(.failure(.invalidResponse))
                return
            }

            completion(request.decode(data))
        }.resume()
    }
}

let client = APIClient()

print("🌐 API Client")
print("Commands: fetch <id> (id between 1 and 200), quit")

apiLoop: while true {
    print("\n> ", terminator: "")

    guard let line = readLine() else {
        print("\nGoodbye!")
        break apiLoop
    }

    let input = line.trimmingCharacters(in: .whitespaces)
    let parts = input.split(separator: " ")

    guard let commandWord = parts.first else {
        continue apiLoop
    }
    let command = String(commandWord)

    switch command {
    case "quit", "exit":
        print("Goodbye!")
        break apiLoop

    case "fetch":
        guard parts.count == 2, let id = Int(parts[1]) else {
            print("Usage: fetch <id>")
            continue apiLoop
        }

        let semaphore = DispatchSemaphore(value: 0)
        client.send(FetchTodoRequest(id: id)) { result in
            switch result {
            case .success(let todo):
                let status = todo.isCompleted ? "done" : "pending"
                print("✅ Todo #\(todo.id): \(todo.title) (\(status))")
            case .failure(let error):
                print("❌ \(error.describe())")
            }
            semaphore.signal()
        }
        semaphore.wait()

    default:
        print("Unknown command. Try: fetch <id>, quit")
    }
}
