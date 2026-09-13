import Foundation

let filePath = "todos.txt"

func loadTodos(from path: String) -> [(text: String, isDone: Bool)] {
    guard let data = FileManager.default.contents(atPath: path),
          let content = String(data: data, encoding: .utf8)
    else {
        return []
    }

    return content.split(separator: "\n").map { line in
        let isDone = line.hasPrefix("[x]")
        let text = line.dropFirst(4).trimmingCharacters(in: .whitespaces)
        return (text: text, isDone: isDone)
    }
}

func saveTodos(_ todos: [(text: String, isDone: Bool)], to path: String) {
    let lines = todos.map { "\($0.isDone ? "[x]" : "[ ]") \($0.text)" }
    let content = lines.joined(separator: "\n")
    FileManager.default.createFile(atPath: path, contents: Data(content.utf8))
}

func printTodos(_ todos: [(text: String, isDone: Bool)]) {
    if todos.isEmpty {
        print("Your todo list is empty.")
        return
    }
    for (index, todo) in todos.enumerated() {
        let mark = todo.isDone ? "x" : " "
        print("\(index). [\(mark)] \(todo.text)")
    }
}

func addTodo(_ text: String, to todos: inout [(text: String, isDone: Bool)]) {
    todos.append((text: text, isDone: false))
}

func toggleTodo(at index: Int, in todos: inout [(text: String, isDone: Bool)]) -> Bool {
    guard todos.indices.contains(index) else { return false }
    todos[index].isDone.toggle()
    return true
}

func removeTodo(at index: Int, from todos: inout [(text: String, isDone: Bool)]) -> Bool {
    guard todos.indices.contains(index) else { return false }
    todos.remove(at: index)
    return true
}

var todos = loadTodos(from: filePath)

print("✅ Todo CLI")
print("Commands: add <text>, done <index>, remove <index>, list, quit")
printTodos(todos)

todoLoop: while true {
    print("\n> ", terminator: "")

    guard let line = readLine() else {
        saveTodos(todos, to: filePath)
        print("\nSaved. Goodbye!")
        break todoLoop
    }

    let input = line.trimmingCharacters(in: .whitespaces)
    let parts = input.split(separator: " ", maxSplits: 1)

    guard let commandWord = parts.first else {
        continue todoLoop
    }

    let command = String(commandWord)
    let argument = parts.count > 1 ? String(parts[1]) : ""

    switch command {
    case "quit", "exit":
        saveTodos(todos, to: filePath)
        print("Saved. Goodbye!")
        break todoLoop

    case "list":
        printTodos(todos)

    case "add":
        guard !argument.isEmpty else {
            print("Usage: add <text>")
            continue todoLoop
        }
        addTodo(argument, to: &todos)
        saveTodos(todos, to: filePath)
        print("Added.")

    case "done":
        guard let index = Int(argument), toggleTodo(at: index, in: &todos) else {
            print("Usage: done <valid index>")
            continue todoLoop
        }
        saveTodos(todos, to: filePath)
        print("Updated.")

    case "remove":
        guard let index = Int(argument), removeTodo(at: index, from: &todos) else {
            print("Usage: remove <valid index>")
            continue todoLoop
        }
        saveTodos(todos, to: filePath)
        print("Removed.")

    default:
        print("Unknown command. Try: add, done, remove, list, quit")
    }
}
