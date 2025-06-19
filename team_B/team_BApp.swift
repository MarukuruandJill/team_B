//
//  team_BApp.swift
//  team_B
//
//  Created by 武井まりあ on 2025/06/10.
// hatsune added firebase

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct team_BApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel() // 🔸 認証状態を監視

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if authViewModel.isLoggedIn {
                    ContentView()
                } else {
                    WelcomeView()
                }
            }
            .environmentObject(authViewModel) // 🔸 すべての画面で使えるように
        }
    }
}
