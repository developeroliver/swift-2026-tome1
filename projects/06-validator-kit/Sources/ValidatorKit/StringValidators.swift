public struct NotEmptyValidator: Validator {
    public init() {}

    public func validate(_ value: String) -> Result<Void, ValidationError> {
        value.isEmpty ? .failure(.empty) : .success(())
    }
}

public struct LengthValidator: Validator {
    private let range: ClosedRange<Int>

    public init(_ range: ClosedRange<Int>) {
        self.range = range
    }

    public func validate(_ value: String) -> Result<Void, ValidationError> {
        if value.count < range.lowerBound {
            return .failure(.tooShort(minimum: range.lowerBound))
        }
        if value.count > range.upperBound {
            return .failure(.tooLong(maximum: range.upperBound))
        }
        return .success(())
    }
}

public struct EmailValidator: Validator {
    public init() {}

    public func validate(_ value: String) -> Result<Void, ValidationError> {
        value.contains("@") && value.contains(".") ? .success(()) : .failure(.invalidEmail)
    }
}
