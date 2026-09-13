public enum ValidationError: Error, Equatable {
    case empty
    case tooShort(minimum: Int)
    case tooLong(maximum: Int)
    case invalidEmail
    case outOfRange
}

public protocol Validator<Value> {
    associatedtype Value
    func validate(_ value: Value) -> Result<Void, ValidationError>
}
