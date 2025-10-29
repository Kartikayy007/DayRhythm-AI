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
    func signInWithGoogle(idToken: String) async {
        errorMessage = nil
        isLoading = true

        let result = await authService.signInWithGoogle(idToken: idToken)

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
}
