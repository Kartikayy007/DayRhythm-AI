//
//  AuthenticationViewModel.swift
//  DayRhythm AI
//
//  Created by kartikay on 29/10/25.
//

import Foundation
import SwiftUI
import Combine

final class AuthenticationViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var otpSent: Bool = false

    private let authService = AuthenticationService.shared
    private let appState = AppState.shared

    @MainActor
    func signUp() async {
        
        errorMessage = nil

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }

        isLoading = true

        let result = await authService.signUp(email: email, password: password)

        isLoading = false

        switch result {
        case .success(let user):
            appState.setAuthenticated(user: user)
            clearFields()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    
    @MainActor
    func signIn() async {
        
        errorMessage = nil

        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }

        isLoading = true

        let result = await authService.signIn(email: email, password: password)

        isLoading = false

        switch result {
        case .success(let user):
            appState.setAuthenticated(user: user)
            clearFields()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    
    @MainActor
    func signInWithApple(idToken: String, nonce: String) async {
        errorMessage = nil
        isLoading = true

        let result = await authService.signInWithApple(idToken: idToken, nonce: nonce)

        isLoading = false

        switch result {
        case .success(let user):
            appState.setAuthenticated(user: user)
            clearFields()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }



    @MainActor
    func signOut() async {
        isLoading = true

        let result = await authService.signOut()

        isLoading = false

        switch result {
        case .success:
            appState.clearAuthentication()
            clearFields()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    

    
    func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
    }

    
    func clearError() {
        errorMessage = nil
    }


    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    @MainActor
    func sendOTP() async {
        errorMessage = nil

        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }

        guard isValidEmail() else {
            errorMessage = "Please enter a valid email address"
            return
        }

        isLoading = true

        let result = await authService.sendOTP(email: email)

        isLoading = false

        switch result {
        case .success:
            otpSent = true
        case .failure(let error):
            errorMessage = error.localizedDescription
            otpSent = false
        }
    }

    @MainActor
    func verifyOTP(code: String) async {
        errorMessage = nil

        guard code.count == 6 else {
            errorMessage = "Please enter the 6-digit code"
            return
        }

        isLoading = true

        let result = await authService.verifyOTP(email: email, code: code)

        isLoading = false

        switch result {
        case .success(let user):
            appState.setAuthenticated(user: user)
            clearFields()
            otpSent = false
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

}
