import SwiftUI

struct CookingData: Identifiable {
    var id = UUID()
    var date: Date
    var name: String
    var image: Image
}

struct PhotoAndName: View {
    let date: Date
    let cookingDataList: [CookingData]
    
    var body: some View {
        // 同じ日付の料理データのみ抽出（時刻を無視）
        let matchedItems = cookingDataList.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
        
        HStack(spacing: 12) {
            ForEach(matchedItems) { data in
                VStack(spacing: 8) {
                    data.image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text(data.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}


struct DayRowView: View {
    let date: Date
    let cookingDataList: [CookingData]
    
    var body: some View {
        HStack(alignment: .center) {
            // 左側：日付と曜日
            HStack(alignment: .bottom, spacing: 4) {
                VStack {
                    Text(dateFormatted(date, format: "M/d"))
                        .font(.headline)
                }
                .frame(width: 60, height: 60)
                .background(isToday(date) ? Color(red: 0.85, green: 0.25, blue: 0.45) : Color(red: 0.95, green: 0.55, blue: 0.70).opacity(0.3))
                .clipShape(Circle())
                .padding(.horizontal, 5)
                
                Text(weekdaySymbol(date))
                    .font(.caption)
            }
            .frame(width: 100, alignment: .leading)
            
            // 右側：写真＋名前
            PhotoAndName(date: date, cookingDataList: cookingDataList)
                .frame(maxWidth: .infinity, alignment: .leading)
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
//

// ユーティリティ関数
func dateFormatted(_ date: Date, format: String) -> String {
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

// Preview（仮データあり）
#Preview {
    let today = Date()
    let sampleData = [
        CookingData(date: today, name: "オムライス", image: Image(systemName: "photo")),
        CookingData(date: today, name: "カレー", image: Image(systemName: "photo")),
        CookingData(date: today.addingTimeInterval(-86400), name: "ラーメン", image: Image(systemName: "photo")) 
    ]
    
    return DayRowView(date: today, cookingDataList: sampleData)
}
