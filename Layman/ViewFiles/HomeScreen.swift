//
//  HomeScreen.swift
//  Layman
//
//  Created by Pranjal Shinde on 31/03/26.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Home Screen")
                .font(.largeTitle)
                .bold()

            Button(action: {
                Task {
                    await authVM.logout()
                }
            }) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .padding(.horizontal, 30)
            }
        }
        .padding()
    }
}
