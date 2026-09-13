import TaskManagerCore
import Foundation

func printTask(_ task: TaskItem) {
    let mark = task.isDone ? "x" : " "
    let shortID = task.id.uuidString.prefix(8)
    let flag: String
    switch task.priority {
    case .low: flag = "🟢"
    case .medium: flag = "🟡"
    case .high: flag = "🔴"
    }
    print("\(shortID) [\(mark)] \(flag) \(task.title)")
}

let repository = FileTaskRepository(path: "tasks.json")
let manager = TaskManager(repository: repository)

do {
    try await manager.load()
} catch {
    print("Could not load saved tasks: \(error)")
}

print("🚀 Swift Task Manager")
print("Commands: add <low|medium|high> <title>, done <id>, remove <id>, list, import <count>, quit")

taskLoop: while true {
    print("\n> ", terminator: "")

    guard let line = readLine() else {
        print("\nGoodbye!")
        break taskLoop
    }

    let input = line.trimmingCharacters(in: .whitespaces)
    let parts = input.split(separator: " ", maxSplits: 2)

    guard let commandWord = parts.first else {
        continue taskLoop
    }
    let command = String(commandWord)

    switch command {
    case "quit", "exit":
        print("Goodbye!")
        break taskLoop

    case "list":
        let tasks = await manager.all()
        if tasks.isEmpty {
            print("No tasks yet.")
        } else {
            for task in tasks {
                printTask(task)
            }
        }

    case "add":
        guard parts.count == 3,
              let priority = TaskItem.Priority(rawValue: String(parts[1]))
        else {
            print("Usage: add <low|medium|high> <title>")
            continue taskLoop
        }
        let title = String(parts[2])
        do {
            let task = try await manager.add(title: title, priority: priority)
            print("Added.")
            printTask(task)
        } catch {
            print("Could not add task: \(error)")
        }

    case "done":
        guard parts.count == 2 else {
            print("Usage: done <id>")
            continue taskLoop
        }
        do {
            try await manager.toggle(idPrefix: String(parts[1]))
            print("Updated.")
        } catch {
            print("Could not update task: \(error)")
        }

    case "remove":
        guard parts.count == 2 else {
            print("Usage: remove <id>")
            continue taskLoop
        }
        do {
            try await manager.remove(idPrefix: String(parts[1]))
            print("Removed.")
        } catch {
            print("Could not remove task: \(error)")
        }

    case "import":
        guard parts.count == 2, let count = Int(parts[1]) else {
            print("Usage: import <count>")
            continue taskLoop
        }
        do {
            let imported = try await manager.importFromRemote(limit: count)
            print("Imported \(imported) tasks from the remote API.")
        } catch {
            print("Import failed: \(error)")
        }

    default:
        print("Unknown command. Try: add, done, remove, list, import, quit")
    }
}
