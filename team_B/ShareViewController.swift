import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RecipeFromFirebase: Identifiable {
    var id: String
    var name: String
    var difficulty: String
    var category: [String]
    var imageUrl: String?
}

struct RecipeShareView: View {
    @State private var shareURL: String = ""
    @State private var showingShareSheet = false
    @State private var recipes: [RecipeFromFirebase] = []
    @State private var errorMessage: String?

    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ヘッダー部分
                ZStack {
                    Color(red: 0.9, green: 0.8, blue: 0.8) // 薄いピンク色
                        .ignoresSafeArea(.all, edges: .top)
                    
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.black)
                                Text("共有してもらおう")
                                    .foregroundColor(.black)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(25)
                        }
                        .sheet(isPresented: $showingShareSheet) {
                            ShareSheet(items: ["レシピを共有しよう！"])
                        }
                        
                        Spacer()
                    }
                }
                .frame(height: 100)
                
                // メインコンテンツ
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 40)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("共有相手の名前を入力")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                        
                        TextField("花子", text: $shareURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 30)
                    
                    Button(action: {
                        addRecipeDeck()
                    }) {
                        Text("レシピデッキを追加")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.8, green: 0.7, blue: 0.7))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
                .background(Color.white)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func addRecipeDeck() {
        // レシピデッキ追加の処理
        print("レシピデッキを取得中: \(shareURL)")
        fetchRecipesForUsername()
        // ここに実際の処理を実装
    }
    
    private func fetchRecipesForUsername() {
        let db = Firestore.firestore()
        
        // 現在ログイン中のユーザーの UID を取得
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("現在のユーザーが取得できません")
            return
        }
        
        // Step 1: ユーザー名 → uid を取得
        db.collection("users")
            .whereField("username", isEqualTo: shareURL)
            .getDocuments { userSnapshot, error in
                if let error = error {
                    print("ユーザー検索エラー: \(error.localizedDescription)")
                    return
                }
                
                guard let userDoc = userSnapshot?.documents.first else {
                    print("ユーザーが見つかりません")
                    return
                }
                
                let uid = userDoc.documentID
                print(uid)
                
                // Step 2: 該当uidのレシピを取得
                db.collection("recipes")
                    .whereField("userId", isEqualTo: uid)
                    .getDocuments { recipeSnapshot, error in
                        if let error = error {
                            print("レシピ取得エラー: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let documents = recipeSnapshot?.documents else { return }
                        
                        self.recipes = documents.compactMap { doc in
                            let data = doc.data()
                            
                            guard let name = data["name"] as? String,
                                  let difficulty = data["difficulty"] as? String,
                                  let category = data["category"] as? [String] else {
                                return nil
                            }
                            
                            let imageUrl = data["imageUrl"] as? String
                            
                            return RecipeFromFirebase(
                                id: doc.documentID,
                                name: name,
                                difficulty: difficulty,
                                category: category,
                                imageUrl: imageUrl
                            )
                        }
                        print("取得したレシピ一覧:")
                        for recipe in self.recipes {
                            print("名前: \(recipe.name), 大変さ: \(recipe.difficulty), カテゴリ: \(recipe.category), 画像URL: \(recipe.imageUrl ?? "なし")")
                        }
                        // Step 3: 各レシピの userId を現在のユーザーIDに上書き
                        // 🔁 レシピを複製して自分の userId で保存
                        for recipe in self.recipes {
                            let newRecipeData: [String: Any] = [
                                "name": recipe.name,
                                "difficulty": recipe.difficulty,
                                "category": recipe.category,
                                "imageUrl": recipe.imageUrl ?? "",
                                "userId": currentUserId,
                                "createdAt": Timestamp()
                            ]
                            
                            db.collection("recipes").addDocument(data: newRecipeData) { error in
                                if let error = error {
                                    print("レシピのコピー保存に失敗: \(error.localizedDescription)")
                                } else {
                                    print("レシピをコピーして保存しました: \(recipe.name)")
                                }
                            }
                        }

                        print("上書きしたレシピ一覧:")
                        for recipe in self.recipes {
                            print("名前: \(recipe.name), 大変さ: \(recipe.difficulty), カテゴリ: \(recipe.category), 画像URL: \(recipe.imageUrl ?? "なし")")
                        }
                        // Step 4: レシピを新規保存（複製）して userId を自分に設定
                        for recipe in self.recipes {
                            let newRecipeData: [String: Any] = [
                                "name": recipe.name,
                                "difficulty": recipe.difficulty,
                                "category": recipe.category,
                                "imageUrl": recipe.imageUrl ?? "",
                                "userId": currentUserId,
                                "createdAt": Timestamp()
                            ]
                            
                            db.collection("recipes").addDocument(data: newRecipeData) { error in
                                if let error = error {
                                    print("レシピのコピー保存に失敗: \(error.localizedDescription)")
                                } else {
                                    print("レシピをコピーして保存しました: \(recipe.name)")
                                }
                            }
                        }
                    }
        }
    }
}

// iOS標準のシェア機能を使用
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct RecipeShareView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeShareView()
    }
}
