import Foundation

enum APIError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case decodingFailed
}

struct Todo: Sendable {
    let id: Int
    let title: String
    let isCompleted: Bool
}

func fetchTodo(id: Int) async throws -> Todo {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/\(id)") else {
        throw APIError.invalidURL
    }

    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode)
    else {
        throw APIError.invalidResponse
    }

    guard
        let raw = try? JSONSerialization.jsonObject(with: data),
        let json = raw as? [String: Any],
        let id = json["id"] as? Int,
        let title = json["title"] as? String,
        let isCompleted = json["completed"] as? Bool
    else {
        throw APIError.decodingFailed
    }

    return Todo(id: id, title: title, isCompleted: isCompleted)
}

actor Statistics {
    private var processed: [Todo] = []
    private var failures = 0

    func record(_ todo: Todo) {
        processed.append(todo)
    }

    func recordFailure() {
        failures += 1
    }

    var summary: String {
        let completed = processed.filter(\.isCompleted).count
        let pending = processed.count - completed
        return "Processed: \(processed.count) (✅ \(completed) done, ⏳ \(pending) pending) — ❌ \(failures) failed"
    }
}

func processConcurrently(ids: [Int], stats: Statistics) async {
    await withTaskGroup(of: Void.self) { group in
        for id in ids {
            group.addTask {
                do {
                    let todo = try await fetchTodo(id: id)
                    await stats.record(todo)
                } catch {
                    await stats.recordFailure()
                }
            }
        }
    }
}

let stats = Statistics()

print("⚡ Concurrent Data Engine")
print("Commands: process <start> <end>, stats, quit")

engineLoop: while true {
    print("\n> ", terminator: "")

    guard let line = readLine() else {
        print("\nGoodbye!")
        break engineLoop
    }

    let input = line.trimmingCharacters(in: .whitespaces)
    let parts = input.split(separator: " ")

    guard let commandWord = parts.first else {
        continue engineLoop
    }
    let command = String(commandWord)

    switch command {
    case "quit", "exit":
        print("Goodbye!")
        break engineLoop

    case "stats":
        print(await stats.summary)

    case "process":
        guard parts.count == 3,
              let start = Int(parts[1]),
              let end = Int(parts[2]),
              start <= end
        else {
            print("Usage: process <start> <end>")
            continue engineLoop
        }

        let ids = Array(start...end)
        let clock = ContinuousClock()
        let elapsed = await clock.measure {
            await processConcurrently(ids: ids, stats: stats)
        }
        print("Processed \(ids.count) items concurrently in \(elapsed)")

    default:
        print("Unknown command. Try: process <start> <end>, stats, quit")
    }
}
