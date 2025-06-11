//
//  ContentView.swift
//  team_B
//
//  Created by 武井まりあ on 2025/06/10.
//

import SwiftUI

struct ContentView: View {
    //タブ項目を保持する
    @State var selection = 1
    var body: some View {
        TabView(selection: $selection) {
            MenuContent().tabItem {
                Text("メニュー")
            }
            RecipeContent().tabItem{
                Text("献立表")
            }
            ShareContent().tabItem{
                Text("共有")
            }
        }
    }
}

#Preview {
    ContentView()
}
