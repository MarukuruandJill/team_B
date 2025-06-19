
import SwiftUI
import FirebaseFirestore

struct RegistrationView: View {
    var body: some View {
        TabView {
            RecordView()
                .tabItem {
                    Label("メニュー", systemImage: "fork.knife")
                }
            
            // 献立表タブ
            Text("献立表")
                .font(.title)
                .tabItem {
                    Label("献立表", systemImage: "calendar.badge.plus")
                }
            
            // 共有タブ
            Text("共有")
                .font(.title)
                .tabItem {
                    Label("共有", systemImage: "square.and.arrow.up")
                }
        }
    }
}


struct RecordView: View {
    @State private var dishName: String = ""
    @State private var selectedDifficulty: String = "普通"
    @State private var selectedCategories: Set<String> = []
    @State private var url: String = ""
    @State private var memo: String = ""
    
    private let difficulties = ["すごく楽", "楽", "普通", "大変"]
    private let categories = ["和食", "洋食", "中華", "韓国", "海外の料理",
                              "野菜", "海鮮", "揚げ物", "鍋・スープ", "その他"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // ヘッダー
                        HStack {
                            Spacer()
                            Text("📝 料理を記録")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color(.systemGray6))
                                .cornerRadius(20)
                            Spacer()
                        }
                        
                        // 料理名
                        Group {
                            Text("料理名")
                                .font(.headline)
                            TextField("例: カレー", text: $dishName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // 大変さ
                        Group {
                            Text("大変さ")
                                .font(.headline)
                            HStack(spacing: 8) {
                                ForEach(difficulties, id: \.self) { diff in
                                    Text(diff)
                                        .font(.subheadline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            selectedDifficulty == diff
                                                ? Color.blue.opacity(0.3)
                                                : Color(.systemGray5)
                                        )
                                        .cornerRadius(16)
                                        .onTapGesture {
                                            selectedDifficulty = diff
                                        }
                                }
                            }
                        }
                        
                        // カテゴリ
                        Group {
                            Text("カテゴリ")
                                .font(.headline)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 10)], spacing: 10) {
                                ForEach(categories, id: \.self) { cat in
                                    Text(cat)
                                        .font(.subheadline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            selectedCategories.contains(cat)
                                                ? Color.green.opacity(0.3)
                                                : Color(.systemGray5)
                                        )
                                        .cornerRadius(16)
                                        .onTapGesture {
                                            if selectedCategories.contains(cat) {
                                                selectedCategories.remove(cat)
                                            } else {
                                                selectedCategories.insert(cat)
                                            }
                                        }
                                }
                            }
                        }
                        
                        // URL
                        Group {
                            Text("URL")
                                .font(.headline)
                            TextField("https://", text: $url)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                        }
                        
                        // メモ
                        Group {
                            Text("メモ")
                                .font(.headline)
                            TextEditor(text: $memo)
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4))
                                )
                        }
                    }
                    .padding()
                }
                
                // 登録ボタン
                Button(action: {
                    saveToFirestore()
                }) {
                    Text("この料理を記録する")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemPink))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .navigationBarHidden(true)
        }
    }
    func saveToFirestore() {
        let db = Firestore.firestore()
        let newRecipe: [String: Any] = [
            "name": dishName,
            "difficulty": selectedDifficulty,
            "category": Array(selectedCategories),
            "url": url,
            "memo": memo,
            "createdAt": Timestamp(),
            "userId": "yourUserId" // 実際はFirebaseAuthなどから取得
        ]

        db.collection("recipes").addDocument(data: newRecipe) { error in
            if let error = error {
                print("保存失敗: \(error.localizedDescription)")
            } else {
                print("保存成功！")
                // 入力フォーム初期化などもここで
            }
        }
    }

}

// プレビュー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}

