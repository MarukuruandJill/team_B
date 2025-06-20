//
//  MenuContent.swift
//  team_B
//
//  Created by 武井まりあ on 2025/06/11.
//

import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI
import FirebaseFirestore

struct MenuContent: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showRegistration = false
    var body: some View {
        VStack(spacing: 20) {
            Text("ようこそ！")
                .font(.title)
            Button(action: {
                                showRegistration = true
                            }) {
                                Text("料理記録へ")
                                    .font(.title2)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color.blue.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
            Button(action: {
                logout()
            }) {
                Text("ログアウト")
                    .font(.title2)
                    .padding()
                    .frame(width: 200)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $showRegistration) {
            RecordView()
        }
    }

    func logout() {
        authViewModel.logout()
    }
}
