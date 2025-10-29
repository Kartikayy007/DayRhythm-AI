//
//  AuthenticationService.swift
//  DayRhythm AI
//
//  Created by kartikay on 29/10/25.
//

import Foundation
import Supabase

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyExists
    case weakPassword
    case networkError
    case invalidEmail
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .emailAlreadyExists:
            return "An account with this email already exists. Try logging in."
        case .weakPassword:
            return "Password must be at least 8 characters long."
        case .networkError:
            return "Network error. Please check your connection."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .unknownError(let message):
            return message
        }
    }
}

final class AuthenticationService {
    static let shared = AuthenticationService()

    private let supabase: SupabaseClient

    private init() {
        supabase = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )
    }

    // MARK: - Email/Password Authentication

    /// Sign up a new user with email and password
    func signUp(email: String, password: String) async -> Result<User, AuthError> {
        // Validate inputs
        guard isValidEmail(email) else {
            return .failure(.invalidEmail)
        }

        guard password.count >= 8 else {
            return .failure(.weakPassword)
        }

        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )

            let supabaseUser = response.user

            let user = User(
                id: supabaseUser.id.uuidString,
                email: supabaseUser.email ?? email,
                createdAt: supabaseUser.createdAt
            )

            return .success(user)
        } catch {
            return .failure(parseSupabaseError(error))
        }
    }

    /// Sign in an existing user with email and password
    func signIn(email: String, password: String) async -> Result<User, AuthError> {
        // Validate inputs
        guard isValidEmail(email) else {
            return .failure(.invalidEmail)
        }

        guard !password.isEmpty else {
            return .failure(.invalidCredentials)
        }

        do {
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )

            let supabaseUser = response.user

            let user = User(
                id: supabaseUser.id.uuidString,
                email: supabaseUser.email ?? email,
                createdAt: supabaseUser.createdAt
            )

            return .success(user)
        } catch {
            return .failure(parseSupabaseError(error))
        }
    }

    func signInWithApple(idToken: String, nonce: String) async -> Result<User, AuthError> {
        do {
            let response = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )

            let supabaseUser = response.user

            let user = User(
                id: supabaseUser.id.uuidString,
                email: supabaseUser.email ?? "",
                createdAt: supabaseUser.createdAt
            )

            return .success(user)
        } catch {
            return .failure(parseSupabaseError(error))
        }
    }

    func signInWithGoogle(idToken: String) async -> Result<User, AuthError> {
        do {
            let response = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken
                )
            )

            let supabaseUser = response.user

            let user = User(
                id: supabaseUser.id.uuidString,
                email: supabaseUser.email ?? "",
                createdAt: supabaseUser.createdAt
            )

            return .success(user)
        } catch {
            return .failure(parseSupabaseError(error))
        }
    }

    func signOut() async -> Result<Void, AuthError> {
        do {
            try await supabase.auth.signOut()
            return .success(())
        } catch {
            return .failure(.unknownError("Failed to sign out"))
        }
    }

    func getCurrentUser() async -> User? {
        guard let session = supabase.auth.currentSession else {
            return nil
        }

        let supabaseUser = session.user

        return User(
            id: supabaseUser.id.uuidString,
            email: supabaseUser.email ?? "",
            createdAt: supabaseUser.createdAt
        )
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func parseSupabaseError(_ error: Error) -> AuthError {
        let errorMessage = error.localizedDescription.lowercased()

        if errorMessage.contains("email") && errorMessage.contains("exists") {
            return .emailAlreadyExists
        } else if errorMessage.contains("password") {
            return .weakPassword
        } else if errorMessage.contains("invalid") || errorMessage.contains("credentials") {
            return .invalidCredentials
        } else if errorMessage.contains("network") {
            return .networkError
        } else {
            return .unknownError(error.localizedDescription)
        }
    }
}
