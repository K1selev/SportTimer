//
//  LoginView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 01.10.2025.
//

import SwiftUI

struct LoginView: View {
    let onContinue: () -> Void
    @StateObject var vm = AuthViewModel(auth: AuthServiceStub())
    @FocusState private var focused: Field?
    enum Field { case email, pwd }

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Hey there,")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.textSecondary)
                Text("Welcome Back")
                    .font(.system(.title, design: .rounded).bold())
            }
            .padding(.top, 24)

            IconTextField(systemImage: "envelope", placeholder: "Email", text: $vm.email, keyboard: .emailAddress, textContentType: .emailAddress)
                .focused($focused, equals: .email)

            IconSecureField(placeholder: "Password", text: $vm.password)
                .focused($focused, equals: .pwd)

            Button("Forgot your password?") {
            }
            .font(.footnote)
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)

            Button {
                    onContinue()

                    // Позже:
                    // Task {
                    //   await vm.login()
                    //   if vm.didAuthSucceed { onContinue() }
                    // }
            } label: { Label(vm.isLoading ? "Please wait…" : "Login", systemImage: "arrow.right.to.line") }
            .buttonStyle(PrimaryGradientButtonStyle())
//            .disabled(!vm.canLogin)
            .padding(.top, 8)

            HStack {
                Rectangle().fill(AppTheme.separator).frame(height: 1)
                Text("Or").foregroundColor(AppTheme.textSecondary)
                Rectangle().fill(AppTheme.separator).frame(height: 1)
            }.padding(.vertical, 8)

            SocialButtons(
                onGoogle: { Task { await vm.loginWithGoogle() } },
                onFacebook: { Task { await vm.loginWithFacebook() } }
            )

            Spacer(minLength: 24)

            HStack(spacing: 4) {
                Text("Don’t have an account yet?")
                    .foregroundColor(AppTheme.textSecondary)
                NavigationLink("Register") {
                    RegisterView(onContinue: onContinue)
                }
            }
            .font(.footnote)
        }
        .padding(.horizontal, 20)
        .background(AppTheme.bg.ignoresSafeArea())
        .alert("Oops", isPresented: .constant(vm.errorMessage != nil), presenting: vm.errorMessage) { _ in
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: { Text($0 ?? "") }
        .navigationBarHidden(true)
    }
}
