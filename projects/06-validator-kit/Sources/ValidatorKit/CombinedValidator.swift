public struct CombinedValidator<Value>: Validator {
    private let validators: [any Validator<Value>]

    public init(_ validators: [any Validator<Value>]) {
        self.validators = validators
    }

    public func validate(_ value: Value) -> Result<Void, ValidationError> {
        for validator in validators {
            let result = validator.validate(value)
            if case .failure = result {
                return result
            }
        }
        return .success(())
    }
}
