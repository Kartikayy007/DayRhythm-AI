//
//  AppState.swift
//  DayRhythm AI
//
//  Created by kartikay on 29/10/25.
//


import Foundation
import SwiftUI
import Combine


final class AppState: ObservableObject {

    static let shared = AppState()

    @Published var currentUser: User? = nil
    @Published var isAuthenticated: Bool = false

    private var authStateTask: Task<Void, Never>?

    private init() {
        checkAuthenticationStatus()
        startAuthStateMonitoring()
    }

    private func checkAuthenticationStatus() {
        Task {
            
            if let user = await AuthenticationService.shared.getCurrentUser() {
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            } else {
                await MainActor.run {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            }
        }
    }

    private func startAuthStateMonitoring() {
        authStateTask = Task {
            await AuthenticationService.shared.startAuthStateListener { [weak self] user in
                guard let self = self else { return }
                await MainActor.run {
                    if let user = user {
                        self.currentUser = user
                        self.isAuthenticated = true
                    } else {
                        self.currentUser = nil
                        self.isAuthenticated = false
                    }
                }
            }
        }
    }

    func setAuthenticated(user: User) {
        self.currentUser = user
        self.isAuthenticated = true
    }

    func clearAuthentication() {
        self.currentUser = nil
        self.isAuthenticated = false
    }

    deinit {
        authStateTask?.cancel()
    }
}
