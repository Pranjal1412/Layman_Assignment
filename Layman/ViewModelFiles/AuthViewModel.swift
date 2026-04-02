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
    
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastActiveDate: Date?
    
    var displayName: String {
        email.isEmpty ? "User" : email.components(separatedBy: "@").first ?? "User"
    }
    
    var isValid: Bool {
        if email.isEmpty || password.isEmpty { return false }
        if mode == .signup { return password == confirmPassword && password.count >= 6 }
        return true
    }
    
    init() {
        loadStreak()
    }
    
    @MainActor
    func performAuth() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        defer {
            Task { await MainActor.run { isLoading = false } }
        }
        
        // Basic validation
        if email.isEmpty {
            await MainActor.run {
                errorMessage = "Email cannot be empty."
                isAuthenticated = false
            }
            return
        }
        
        if password.isEmpty {
            await MainActor.run {
                errorMessage = "Password cannot be empty."
                isAuthenticated = false
            }
            return
        }
        
        if mode == .signup {
            if password.count < 6 {
                await MainActor.run {
                    errorMessage = "Password must be at least 6 characters."
                    isAuthenticated = false
                }
                return
            }
            if password != confirmPassword {
                await MainActor.run {
                    errorMessage = "Passwords do not match."
                    isAuthenticated = false
                }
                return
            }
        }
        
        // Supabase authentication
        do {
            switch mode {
            case .signup:
                let _ = try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
            case .login:
                let _ = try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
            }
            
            // Success → update on main thread
            await MainActor.run {
                isAuthenticated = true
            }
            
        } catch {
            // Handle error on main thread
            let description = error.localizedDescription.lowercased()
            await MainActor.run {
                if mode == .signup && (description.contains("already") || description.contains("registered")) {
                    errorMessage = "User already exists."
                } else {
                    errorMessage = error.localizedDescription
                }
                isAuthenticated = false
            }
        }
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
    
    func checkSession() {
        if let session = SupabaseManager.shared.client.auth.currentSession,
           let userEmail = session.user.email {  
            email = userEmail
            isAuthenticated = true
        } else {
            email = ""
            isAuthenticated = false
        }
    }
    
    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        guard let lastDate = lastActiveDate else {
            // First time user
            currentStreak = 1
            longestStreak = max(longestStreak, currentStreak)
            lastActiveDate = today
            saveStreak()
            return
        }
        
        let lastDay = Calendar.current.startOfDay(for: lastDate)
        let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        if diff == 0 {
            // Same day → do nothing
            return
        } else if diff == 1 {
            // Consecutive day → increase streak
            currentStreak += 1
        } else {
            // Missed day → reset streak
            currentStreak = 1
        }
        
        longestStreak = max(longestStreak, currentStreak)
        lastActiveDate = today
        
        saveStreak()
    }
    
    private func saveStreak() {
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(longestStreak, forKey: "longestStreak")
        UserDefaults.standard.set(lastActiveDate, forKey: "lastActiveDate")
    }
    
    func loadStreak() {
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        longestStreak = UserDefaults.standard.integer(forKey: "longestStreak")
        lastActiveDate = UserDefaults.standard.object(forKey: "lastActiveDate") as? Date
    }
}
