//
//  RegisterToCalendarView.swift
//  team_B
//
//  Created by 武井まりあ on 2025/06/14.
//

import SwiftUI

struct RegisterToCalendarView: View {
    @State private var selectedDate = Date()
    @State private var mealName: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 16){
                HStack{
                    Label("料理を記録", systemImage: "calendar")
                        .font(.headline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color("AccentPink"))
                        .cornerRadius(20)
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.95, green: 0.55, blue: 0.70).opacity(0.3))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("日付を選択")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .accentColor(.pink)
                        .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("料理名から検索")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal)
                    
                    TextField("例）オムライス", text: $mealName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // 登録ボタン
                Button(action: {
                    // カレンダーに記録処理を書く
                    dismiss()
                    
                }) {
                    Text("この料理を\nカレンダーに記録する")
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("AccentPink"))
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .frame(width: 300, height: 100)
                .background(Color(red: 0.95, green: 0.55, blue: 0.70).opacity(0.3))
                .cornerRadius(50)
                
                Spacer()
                
            }
        }
    }
}

#Preview {
    RegisterToCalendarView()
}
