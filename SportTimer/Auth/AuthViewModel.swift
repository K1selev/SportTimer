//
//  AuthViewModel.swift
//  SportTimer
//
//  Created by Сергей Киселев on 01.10.2025.
//

import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var acceptedTerms = false

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didAuthSucceed = false

    private let auth: AuthServiceProtocol
    init(auth: AuthServiceProtocol) { self.auth = auth }

    var canRegister: Bool {
        !firstName.isEmpty && !lastName.isEmpty &&
        email.isValidEmail && password.count >= 6 && acceptedTerms && !isLoading
    }

    var canLogin: Bool {
        email.isValidEmail && password.count >= 6 && !isLoading
    }

    func register() async {
        guard canRegister else { return }
        await run {
            try await auth.signUp(email: email, password: password,
                                  profile: UserProfile(firstName: firstName, lastName: lastName))
        }
    }

    func login() async {
        guard canLogin else { return }
        await run { try await auth.signIn(email: email, password: password) }
        print("HELLLL")
    }

    func loginWithGoogle() async { await run { try await auth.signInWithGoogle() } }
    func loginWithFacebook() async { await run { try await auth.signInWithFacebook() } }

    private func run(_ block: () async throws -> Void) async {
        isLoading = true; errorMessage = nil
        do { try await block(); didAuthSucceed = true }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}

private extension String {
    var isValidEmail: Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return range(of: pattern, options: .regularExpression) != nil
    }
}



protocol AuthServiceProtocol {
    func signUp(email: String, password: String, profile: UserProfile) async throws
    func signIn(email: String, password: String) async throws
    func signInWithGoogle() async throws
    func signInWithFacebook() async throws
}

struct AuthServiceStub: AuthServiceProtocol {
    func signUp(email: String, password: String, profile: UserProfile) async throws { try await Task.sleep(nanoseconds: 500_000_000) }
    func signIn(email: String, password: String) async throws { try await Task.sleep(nanoseconds: 300_000_000) }
    func signInWithGoogle() async throws { try await Task.sleep(nanoseconds: 200_000_000) }
    func signInWithFacebook() async throws { try await Task.sleep(nanoseconds: 200_000_000) }
}


struct UserProfile { let firstName: String; let lastName: String }


