//
//  ContentView.swift
//  team_B
//
//  Created by 武井まりあ on 2025/06/10.
//

import SwiftUI

struct TabBarModifier: ViewModifier {
    init(backgroundColor: UIColor) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        
        UITabBar.appearance().standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    func body(content: Content) -> some View {
        content
    }
}

struct ContentView: View {
    //タブ項目を保持する
    @State var selection = 0
    var body: some View {
        TabView(selection: $selection) {
            MenuContent().tabItem {
                Label("メニュー", systemImage: "fork.knife")
            }.tag(0)
            
            RecipeContent().tabItem{
                Label("献立表", systemImage: "calendar.badge.plus")
            }.tag(1)
            
            ShareContent().tabItem{
                Label("共有", systemImage: "square.and.arrow.up")
            }.tag(2)
        }
        .modifier(
            TabBarModifier(
                backgroundColor: UIColor(red: 0.95, green: 0.55, blue: 0.70, alpha: 0.3)
            )
        )
    }
}

#Preview {
    ContentView()
}
