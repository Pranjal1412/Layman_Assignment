//
//  UserProfileScreen.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import SwiftUI

struct UserProfileScreen: View {

    @EnvironmentObject var authVM: AuthViewModel
    var onSignOut: (() -> Void)? // <- add this
    @State private var animateContent = false
    @State private var isSearching = false
    @State private var searchText = ""


    var body: some View {
        ZStack {

            VStack(spacing: 0) {

                Layman_NavBar(title: "Profile", hideSearch: true, searchText: $searchText, isSearching: $isSearching)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        profileHeader
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 18)
                        statsSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 24)
                        accountDetails
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30)
                        signOutButton
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 36)
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
                .background(Color.viewBackground)
            }
        }
        .onAppear {
            animateContent = false
            withAnimation(.easeOut(duration: 0.55)) {
                animateContent = true
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 10) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 90, height: 90)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 42))
                            .foregroundColor(Color.accentColor.opacity(0.6))
                    )
            }

            // Name
            Text(authVM.displayName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.primaryText)

            // Email
            Text(authVM.email)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.primaryText.opacity(0.5))
        }
        .animation(.easeOut(duration: 0.4), value: animateContent)
    }
    private var statsSection: some View {
        HStack(spacing: 16) {
            
            StatCardView(
                value: "\(authVM.currentStreak)",
                label: "CURRENT STREAK"
            )
            
            StatCardView(
                value: "\(authVM.longestStreak)",
                label: "LONGEST STREAK"
            )
        }
        .padding(.horizontal, 20)
        .animation(.easeOut(duration: 0.45), value: animateContent)
    }

    private var accountDetails: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Section label
            Text("ACCOUNT DETAILS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.primaryText.opacity(0.4))
                .kerning(1.2)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

            // Card
            VStack(spacing: 0) {
                ProfileDetailRow(
                    icon: "person.fill",
                    label: "FULL NAME",
                    value: authVM.displayName,
                    accent: Color.accentColor,
                    primaryText: Color.primaryText
                )

                Divider()
//                    .padding(.leading, 56)
                    .overlay(Color.primaryText.opacity(0.07))

                ProfileDetailRow(
                    icon: "envelope.fill",
                    label: "EMAIL ADDRESS",
                    value: authVM.email,
                    accent: Color.accent,
                    primaryText: Color.primaryText
                )
            }
            .background(Color.cellBackground)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .shadow(color: Color.accentColor.opacity(0.2), radius: 16, x: 0, y: 2)
        }
        .animation(.easeOut(duration: 0.5), value: animateContent)
    }

    // MARK: - Sign Out Button

    private var signOutButton: some View {
        Button(action: {
            Task {
                onSignOut?()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .medium))
                Text("Sign Out")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(Color.accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .cornerRadius(26)
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.accentColor.opacity(0.4), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
        .scaleEffect(animateContent ? 1 : 0.96)
        .animation(.easeOut(duration: 0.55), value: animateContent)
    }
}

// MARK: - Profile Detail Row

struct ProfileDetailRow: View {
    let icon: String
    let label: String
    let value: String
    let accent: Color
    let primaryText: Color

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(Color.accentColor)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(primaryText.opacity(0.4))
                    .kerning(0.8)

                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(primaryText)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct StatCardView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.accentColor)
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.primaryText.opacity(0.5))
                .kerning(1.1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color.cellBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
    }
}

#Preview {
    UserProfileScreen()
        .environmentObject(AuthViewModel())
}
