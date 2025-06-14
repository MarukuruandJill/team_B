//
//  DayRowView.swift
//  team_B
//
//  Created by 武井まりあ on 2025/06/11.
//

import SwiftUI

struct DayRowView: View {
    let date: Date
    
    var body: some View {
        HStack{
            VStack{
                Text(dateFormatted(date, format: "M/d"))
                    .font(.headline)
                Text(weekdaySymbol(date))
                    .font(.caption)
            }
            .frame(width: 60, height: 60)
            .background(isToday(date) ? Color(red: 0.85, green: 0.25, blue: 0.45) : Color(red: 0.95, green: 0.55, blue: 0.70).opacity(0.3))
            .clipShape(Circle())
            .padding(.horizontal, 5)
            
            Spacer(minLength: 50)
            
            Button(action: {
                
            }){
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 90)
        .padding(.horizontal, 5)
        .padding(.bottom, 4)
        .padding(.vertical, 6)
        .contentMargins(.bottom, 3)
        .overlay(
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addLine(to: CGPoint(x: width, y: height))
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundColor(.black)
            }
        )
    }
}

func dateFormatted(_ date: Date, format: String) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: date)
}

func weekdaySymbol(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    formatter.dateFormat = "E"
    return formatter.string(from: date)
}

func isToday(_ date: Date) -> Bool {
    Calendar.current.isDateInToday(date)
}

#Preview {
    DayRowView(date: Date())
}


