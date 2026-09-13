import XCTest
@testable import ValidatorKit

final class ValidatorKitTests: XCTestCase {
    func testNotEmptyValidatorRejectsEmptyString() {
        guard case .failure(let error) = NotEmptyValidator().validate("") else {
            return XCTFail("Expected failure")
        }
        XCTAssertEqual(error, .empty)
    }

    func testNotEmptyValidatorAcceptsNonEmptyString() {
        guard case .success = NotEmptyValidator().validate("hello") else {
            return XCTFail("Expected success")
        }
    }

    func testLengthValidator() {
        let validator = LengthValidator(3...10)

        guard case .failure(let error) = validator.validate("ab") else {
            return XCTFail("Expected failure")
        }
        XCTAssertEqual(error, .tooShort(minimum: 3))

        guard case .success = validator.validate("hello") else {
            return XCTFail("Expected success")
        }
    }

    func testEmailValidator() {
        guard case .failure(let error) = EmailValidator().validate("not-an-email") else {
            return XCTFail("Expected failure")
        }
        XCTAssertEqual(error, .invalidEmail)

        guard case .success = EmailValidator().validate("ada@example.com") else {
            return XCTFail("Expected success")
        }
    }

    func testRangeValidator() {
        let validator = RangeValidator(0...120)

        guard case .failure(let error) = validator.validate(150) else {
            return XCTFail("Expected failure")
        }
        XCTAssertEqual(error, .outOfRange)

        guard case .success = validator.validate(36) else {
            return XCTFail("Expected success")
        }
    }

    func testCombinedValidatorStopsAtFirstFailure() {
        let validator = CombinedValidator<String>([NotEmptyValidator(), LengthValidator(3...10)])

        guard case .failure(let error) = validator.validate("") else {
            return XCTFail("Expected failure on empty string")
        }
        XCTAssertEqual(error, .empty)

        guard case .failure(let secondError) = validator.validate("ab") else {
            return XCTFail("Expected failure on too-short string")
        }
        XCTAssertEqual(secondError, .tooShort(minimum: 3))

        guard case .success = validator.validate("abcd") else {
            return XCTFail("Expected success")
        }
    }
}
