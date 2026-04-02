//
//  AuthScreen.swift
//  Layman
//
//  Created by Pranjal Shinde on 31/03/26.
//

import SwiftUI

struct AuthScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var animateCardIn = false

    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.accent
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white], for: .selected
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.gray], for: .normal
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }

                VStack {
                    Spacer()

                    VStack {
                        Spacer()

                        VStack(spacing: 16) {

                            // Segmented Control
                            Picker("", selection: $viewModel.mode) {
                                Text("Login").tag(AuthViewModel.Mode.login)
                                Text("Sign Up").tag(AuthViewModel.Mode.signup)
                            }
                            .pickerStyle(.segmented)
                            .cornerRadius(10)
                            .padding(.bottom, 10)
                            .onChange(of: viewModel.mode) {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }

                            // Email
                            CustomTextField(
                                text: $viewModel.email,
                                placeholder: "Email",
                                systemImage: "envelope"
                            )

                            // Password
                            CustomSecureField(
                                text: $viewModel.password,
                                placeholder: "Password",
                                showText: $showPassword
                            )

                            // Confirm Password (only in signup)
                            if viewModel.mode == .signup {
                                CustomSecureField(
                                    text: $viewModel.confirmPassword,
                                    placeholder: "Confirm Password",
                                    showText: $showConfirmPassword
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }

                            // Error message
                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.top, 5)
                                    .transition(.opacity)
                            }

                            // CTA Button
                            Button(action: {
                                Task {
                                    await viewModel.performAuth()
                                    if viewModel.isAuthenticated {
                                        isLoggedIn = true // persist login state
                                    }
                                }
                            }) {
                                Text(viewModel.mode == .login ? "Login" : "Create Account")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color("AccentColor"))
                                    .foregroundColor(.white)
                                    .cornerRadius(25)
                            }

                        }
                        .padding(20)
                        .background(formCardBackground)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 6)
                        .padding(.horizontal, 20)
                        .opacity(animateCardIn ? 1 : 0)
                        .offset(y: animateCardIn ? 0 : 36)
                        .animation(.easeInOut(duration: 0.6), value: viewModel.mode)

                        Spacer()
                    }

                    Spacer()
                }

                // Loader overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Please wait...")
                        .padding()
                        .background(Color("AccentColor").opacity(0.1))
                        .foregroundColor(Color("AccentColor"))
                        .tint(Color("AccentColor"))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: viewModel.isLoading)
            .onAppear {
                animateCardIn = false
                withAnimation(.easeOut(duration: 0.65)) {
                    animateCardIn = true
                }
            }
        }
    }

    private var backgroundGradient: LinearGradient {
        let edgeColor = colorScheme == .dark
            ? Color(red: 0.22, green: 0.17, blue: 0.14)
            : Color(red: 0.906, green: 0.784, blue: 0.706)
        let middleColor = colorScheme == .dark ? Color.viewBackground : .white

        return LinearGradient(
            colors: [edgeColor, middleColor, edgeColor],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var formCardBackground: Color {
        colorScheme == .dark
            ? Color(red: 0.16, green: 0.13, blue: 0.11)
            : Color(red: 1.0, green: 0.94, blue: 0.88)
    }
}

// MARK: - Custom TextField
struct CustomTextField: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var text: String
    var placeholder: String
    var systemImage: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.gray)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(placeholderColor)
                }
                TextField("", text: $text)
                    .foregroundColor(textColor)
            }
        }
        .padding()
        .background(fieldBackground)
        .cornerRadius(12)
    }

    private var placeholderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.45) : Color.orange.opacity(0.5)
    }

    private var textColor: Color {
        colorScheme == .dark ? Color.primaryText : Color("AccentColor")
    }

    private var fieldBackground: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.5)
    }
}

// MARK: - Custom Secure Field
struct CustomSecureField: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var text: String
    var placeholder: String
    @Binding var showText: Bool

    var body: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.gray)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(placeholderColor)
                }
                if showText {
                    TextField("", text: $text)
                        .foregroundColor(textColor)
                } else {
                    SecureField("", text: $text)
                        .foregroundColor(textColor)
                }
            }

            Button(action: {
                showText.toggle()
            }) {
                Image(systemName: showText ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(fieldBackground)
        .cornerRadius(12)
    }

    private var placeholderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.45) : Color.orange.opacity(0.5)
    }

    private var textColor: Color {
        colorScheme == .dark ? Color.primaryText : Color("AccentColor")
    }

    private var fieldBackground: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.5)
    }
}

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}

#Preview {
    AuthScreen()
}
