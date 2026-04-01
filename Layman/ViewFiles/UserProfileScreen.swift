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

    var body: some View {
        ZStack {

            VStack(spacing: 0) {

                Layman_NavBar(title: "Profile", hideSearch: true)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        profileHeader
                        accountDetails
                        signOutButton
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
                .background(Color.viewBackground)
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
    }

    // MARK: - Account Details

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
                    .padding(.leading, 56)
                    .overlay(Color.primaryText.opacity(0.07))

                ProfileDetailRow(
                    icon: "envelope.fill",
                    label: "EMAIL ADDRESS",
                    value: authVM.email,
                    accent: Color.accent,
                    primaryText: Color.primaryText
                )
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .shadow(color: Color.primaryText.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Sign Out Button

    private var signOutButton: some View {
        Button(action: {
            Task {
                await authVM.logout()
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
            .background(Color.white)
            .cornerRadius(26)
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.accentColor.opacity(0.4), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
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

// MARK: - Preview

#Preview {
    UserProfileScreen()
        .environmentObject(AuthViewModel())
}
