import Testing
@testable import TaskManagerCore

@Test func addingATaskPersistsIt() async throws {
    let repository = InMemoryTaskRepository()
    let manager = TaskManager(repository: repository)

    try await manager.add(title: "Write the book", priority: .high)

    let tasks = await manager.all()
    #expect(tasks.count == 1)
    #expect(tasks.first?.title == "Write the book")
    #expect(tasks.first?.isDone == false)
}

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

@Test func toggleAndRemoveWorkByIDPrefix() async throws {
    let repository = InMemoryTaskRepository()
    let manager = TaskManager(repository: repository)

    let task = try await manager.add(title: "Read a chapter", priority: .medium)
    let prefix = String(task.id.uuidString.prefix(4))

    try await manager.toggle(idPrefix: prefix)
    var tasks = await manager.all()
    #expect(tasks.first?.isDone == true)

    try await manager.remove(idPrefix: prefix)
    tasks = await manager.all()
    #expect(tasks.isEmpty)
}

@Test func loadReadsFromTheInjectedRepository() async throws {
    let seedTask = TaskItem(title: "Pre-existing task", priority: .low)
    let repository = InMemoryTaskRepository(seed: [seedTask])
    let manager = TaskManager(repository: repository)

    try await manager.load()

    let tasks = await manager.all()
    #expect(tasks == [seedTask])
}
