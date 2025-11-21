//
//  RegisterView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 01.10.2025.
//

import SwiftUI

struct RegisterView: View {
    let onContinue: () -> Void
    @StateObject var vm = AuthViewModel(auth: AuthServiceStub())
    @FocusState private var focused: Field?
    enum Field { case first, last, email, pwd }

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Hey there,")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
                Text("Create an Account")
                    .font(.system(.title, design: .rounded).bold())
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 24)

            IconTextField(systemImage: "person", placeholder: "First Name", text: $vm.firstName, autocapitalization: .words)
                .focused($focused, equals: .first)
            IconTextField(systemImage: "person", placeholder: "Last Name", text: $vm.lastName, autocapitalization: .words)
                .focused($focused, equals: .last)
            IconTextField(systemImage: "envelope", placeholder: "Email", text: $vm.email, keyboard: .emailAddress, textContentType: .emailAddress)
                .focused($focused, equals: .email)
            IconSecureField(placeholder: "Password", text: $vm.password)
                .focused($focused, equals: .pwd)

            Toggle(isOn: $vm.acceptedTerms) {
                HStack(spacing: 4) {
                    Text("By continuing you accept our")
                    Button("Privacy Policy") {}
                    Text("and")
                    Button("Term of Use") {}
                }
            }
            .toggleStyle(CheckboxToggleStyle())
            .padding(.top, 4)

            Button {
                onContinue()

                // Task {
                //     await vm.register()
                //     if vm.didAuthSucceed { onContinue() }
                // }
            } label: { Text(vm.isLoading ? "Please wait…" : "Register") }
            .buttonStyle(PrimaryGradientButtonStyle())
//            .disabled(!vm.canRegister)
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
                Text("Already have an account?")
                    .foregroundColor(AppTheme.textSecondary)
                NavigationLink("Login") {
                    LoginView(onContinue: onContinue)
                }
            }
            .font(.footnote)
        }
        .padding(.horizontal, 20)
        .background(AppTheme.bg.ignoresSafeArea())
        .alert("Oops", isPresented: .constant(vm.errorMessage != nil), presenting: vm.errorMessage) { _ in
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: { Text($0 ?? "") }
        .onSubmit { // return key navigation
            switch focused {
            case .first: focused = .last
            case .last:  focused = .email
            case .email: focused = .pwd
            default:     focused = nil
            }
        }
        .navigationBarHidden(true)
    }
}
