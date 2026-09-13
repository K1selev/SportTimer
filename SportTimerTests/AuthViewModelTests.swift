import XCTest
@testable import SportTimer

@MainActor
final class AuthViewModelTests: XCTestCase {
    func testCanRegisterRequiresValidInputsAndAcceptedTerms() {
        let vm = AuthViewModel(auth: AuthServiceStub())

        vm.firstName = "Sergey"
        vm.lastName = "Kiselev"
        vm.email = "sergey@example.com"
        vm.password = "123456"

        XCTAssertFalse(vm.canRegister)

        vm.acceptedTerms = true

        XCTAssertTrue(vm.canRegister)
    }

    func testCanLoginRejectsInvalidEmailAndShortPassword() {
        let vm = AuthViewModel(auth: AuthServiceStub())

        vm.email = "not-an-email"
        vm.password = "12345"

        XCTAssertFalse(vm.canLogin)

        vm.email = "sergey@example.com"
        vm.password = "123456"

        XCTAssertTrue(vm.canLogin)
    }

    func testLoginSetsSuccessFlagWithStubService() async {
        let vm = AuthViewModel(auth: AuthServiceStub())
        vm.email = "sergey@example.com"
        vm.password = "123456"

        await vm.login()

        XCTAssertTrue(vm.didAuthSucceed)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }
}
