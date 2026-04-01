//
//  AuthViewModel.swift
//  Layman
//
//  Created by Pranjal Shinde on 31/03/26.
//

import SwiftUI
import Combine
import Supabase

class AuthViewModel: ObservableObject {
    
    enum Mode { case login, signup }
    
    @Published var mode: Mode = .login
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading = false   
    
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    
    var displayName: String {
        email.isEmpty ? "User" : email.components(separatedBy: "@").first ?? "User"
    }
    
    var isValid: Bool {
        if email.isEmpty || password.isEmpty { return false }
        if mode == .signup { return password == confirmPassword && password.count >= 6 }
        return true
    }
    
    @MainActor
    func performAuth() async {
        isLoading = true
        // Reset error
        errorMessage = nil
        
        // Basic validation
        if email.isEmpty {
            errorMessage = "Email cannot be empty."
            isAuthenticated = false
            return
        }
        if password.isEmpty {
            errorMessage = "Password cannot be empty."
            isAuthenticated = false
            return
        }
        if mode == .signup {
            if password.count < 6 {
                errorMessage = "Password must be at least 6 characters."
                isAuthenticated = false
                return
            }
            if password != confirmPassword {
                errorMessage = "Passwords do not match."
                isAuthenticated = false
                return
            }
        }
        
        // Call Supabase
        do {
            switch mode {
            case .signup:
                let _ = try await SupabaseManager.shared.client.auth.signUp(
                    email: email,
                    password: password
                )
                isAuthenticated = true

            case .login:
                let _ = try await SupabaseManager.shared.client.auth.signIn(
                    email: email,
                    password: password
                )
                isAuthenticated = true
            }
        } catch {
            let description = error.localizedDescription.lowercased()
            if mode == .signup && (description.contains("already") || description.contains("registered")) {
                errorMessage = "User already exists."
            } else {
                errorMessage = error.localizedDescription
            }
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    private func signup() async {
        do {
            try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
            let session = try await SupabaseManager.shared.client.auth.session
            await MainActor.run {
                isAuthenticated = !session.accessToken.isEmpty
                errorMessage = isAuthenticated ? nil : "Signup failed"
            }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
    
    private func login() async {
        do {
            try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
            let session = try await SupabaseManager.shared.client.auth.session
            await MainActor.run {
                isAuthenticated = !session.accessToken.isEmpty
                errorMessage = isAuthenticated ? nil : "Login failed"
            }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
    
    func logout() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
            await MainActor.run { isAuthenticated = false }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
    
    func checkSession() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            await MainActor.run {
                isAuthenticated = !session.accessToken.isEmpty
            }
        } catch {
            await MainActor.run {
                isAuthenticated = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
