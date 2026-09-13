import ValidatorKit

func check<V: Validator>(_ validator: V, _ value: V.Value, label: String) {
    switch validator.validate(value) {
    case .success:
        print("✅ \(label): valid")
    case .failure(let error):
        print("❌ \(label): \(error)")
    }
}

let usernameValidator = CombinedValidator<String>([
    NotEmptyValidator(),
    LengthValidator(3...20)
])

check(usernameValidator, "ab", label: "username")
check(usernameValidator, "ada_lovelace", label: "username")

let emailValidator = EmailValidator()
check(emailValidator, "not-an-email", label: "email")
check(emailValidator, "ada@example.com", label: "email")

let ageValidator = RangeValidator(0...120)
check(ageValidator, 150, label: "age")
check(ageValidator, 36, label: "age")
