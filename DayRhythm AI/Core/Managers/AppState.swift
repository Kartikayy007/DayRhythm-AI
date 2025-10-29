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

    private init() {
        checkAuthenticationStatus()
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

    
    func setAuthenticated(user: User) {
        self.currentUser = user
        self.isAuthenticated = true
    }

    
    func clearAuthentication() {
        self.currentUser = nil
        self.isAuthenticated = false
    }
}
