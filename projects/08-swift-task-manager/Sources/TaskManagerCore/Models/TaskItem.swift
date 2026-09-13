import Foundation

public struct TaskItem: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var isDone: Bool
    public var priority: Priority

    public init(id: UUID = UUID(), title: String, isDone: Bool = false, priority: Priority = .medium) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.priority = priority
    }

    public enum Priority: String, Codable, Sendable, CaseIterable, Comparable {
        case low
        case medium
        case high

        private var rank: Int {
            switch self {
            case .low: 0
            case .medium: 1
            case .high: 2
            }
        }

        public static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rank < rhs.rank
        }
    }
}
