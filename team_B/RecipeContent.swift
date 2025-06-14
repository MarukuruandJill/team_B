//
//  RecipeContent.swift
//  team_B
//
//  Created by 武井まりあ on 2025/06/11.
//

import SwiftUI

func sundayFor(date: Date) -> Date {
    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: date) // 日曜=1
    return calendar.date(byAdding: .day, value: -((weekday + 6) % 7), to: date)!
}

struct RecipeContent: View {
    let startDate: Date?
    @State private var weekStartDate = Date()
    
    init(startDate: Date? = nil) {
        self.startDate = startDate
        let baseDate = startDate ?? Date()
        _weekStartDate = State(initialValue: sundayFor(date: baseDate))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ヘッダー部分
                HStack {
                    Button(action: {
                        weekStartDate = Calendar.current.date(byAdding: .day, value: -7, to: weekStartDate)!
                    }) {
                        Text("前の週")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .foregroundColor(.brown)
                        Text("献立カレンダー")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    
                    Button(action: {
                        weekStartDate = Calendar.current.date(byAdding: .day, value: 7, to: weekStartDate)!
                    }) {
                        Text("次の週")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(red: 0.95, green: 0.55, blue: 0.70).opacity(0.3))
                .frame(maxWidth: .infinity)
                
                // 7日分の行
                ForEach(0..<7, id: \.self) { i in
                    if let date = Calendar.current.date(byAdding: .day, value: i, to: weekStartDate) {
                        DayRowView(date: date)
                    }
                }
                
                Spacer(minLength: 5)
                HStack{
                    Spacer(minLength: 330)
                    Button(action: {
                        
                    }){
                        HStack{
                            HStack{
                                Image(systemName: "plus.app")
                            }
                            .frame(width: 60, height: 60)
                            .background( Color(red: 0.95, green: 0.55, blue: 0.70).opacity(0.3))
                            .clipShape(Circle())
                            .padding(.horizontal, 5)
                            .cornerRadius(20)
                            Spacer()
                        }
                    }
                    
                }
                Spacer(minLength: 5)
            }
            .navigationBarHidden(true) // ナビゲーションバー非表示（必要なら）
        }
    }
}

#Preview {
    RecipeContent()
}
