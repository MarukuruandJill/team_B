import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Recipe: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var userId: String
}

struct RegisterToCalendarView: View {
    @State private var mealName: String = ""
    @State private var selectedDate = Date()
    @State private var suggestions: [Recipe] = []
    @State private var selectedRecipe: Recipe? = nil
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // ヘッダー
                HStack {
                    Label("料理を記録", systemImage: "calendar")
                        .font(.headline)
                        .padding(.horizontal, 3)
                        .padding(.vertical, 12)
                        .background(Color("AccentPink"))
                        .cornerRadius(20)
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.95, green: 0.55, blue: 0.70).opacity(0.3))
                
                // 日付選択
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
                
                // 検索ボックス
                VStack(alignment: .leading, spacing: 4) {
                    Text("料理名から検索")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal)
                    
                    TextField("例）オムライス", text: $mealName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: mealName) { newValue in
                            fetchSuggestions(for: newValue)
                        }
                }
                
                // 候補リスト
                if !suggestions.isEmpty {
                    List {
                        ForEach(suggestions) { recipe in
                            Button(action: {
                                self.mealName = recipe.name
                                self.selectedRecipe = recipe
                                self.suggestions = []
                            }) {
                                Text(recipe.name)
                            }
                        }
                    }
                    .frame(height: 150)
                }
                
                Spacer()
                
                // 登録ボタン
                Button(action: {
                    guard let selected = selectedRecipe else {
                        print("レシピを選択してください")
                        return
                    }
                    guard let uid = Auth.auth().currentUser?.uid else {
                        print("ユーザーがログインしていません")
                        return
                    }
                    let db = Firestore.firestore()
                    let newMealData: [String: Any] = [
                        "date": Timestamp(date: selectedDate),
                        "name": selected.name,
                        "userId": uid
                    ]
                    
                    db.collection("meals").addDocument(data: newMealData) { error in
                        if let error = error {
                            print("Error writing to Firestore: \(error.localizedDescription)")
                        } else {
                            print("✅ 登録成功")
                            dismiss()
                        }
                    }
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
    
    private func fetchSuggestions(for query: String) {
        guard !query.isEmpty else {
            self.suggestions = []
            return
        }
        
        let db = Firestore.firestore()
        db.collection("recipes")
            .order(by: "name")
            .start(at: [query])
            .end(at: [query + "\u{f8ff}"])
            .limit(to: 10)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching suggestions: \(error)")
                    return
                }
                
                guard let docs = snapshot?.documents else { return }
                
                self.suggestions = docs.compactMap { doc in
                    try? doc.data(as: Recipe.self)
                }
            }
    }
}

#Preview {
    RegisterToCalendarView()
}
