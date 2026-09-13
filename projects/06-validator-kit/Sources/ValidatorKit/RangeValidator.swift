public struct RangeValidator<Bound: Comparable>: Validator {
    private let range: ClosedRange<Bound>

    public init(_ range: ClosedRange<Bound>) {
        self.range = range
    }

    public func validate(_ value: Bound) -> Result<Void, ValidationError> {
        range.contains(value) ? .success(()) : .failure(.outOfRange)
    }
}
