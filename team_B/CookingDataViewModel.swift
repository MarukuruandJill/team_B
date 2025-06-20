import FirebaseFirestore
import FirebaseAuth

class CookingDataViewModel: ObservableObject {
    @Published var cookingDataList: [CookingData] = []
    
    func fetchCookingData() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("現在のユーザーIDが取得できません")
            return
        }
        let db = Firestore.firestore()
        
        // まずrecipesコレクションからレシピ名と画像URLの辞書を作成
        db.collection("recipes").getDocuments { recipeSnapshot, error in
            if let error = error {
                print("Error fetching recipes: \(error.localizedDescription)")
                return
            }
            
            guard let recipeDocs = recipeSnapshot?.documents else { return }
            
            
            var recipeMap = [String: String]()
            for doc in recipeDocs {
                let data = doc.data()
                if let name = data["name"] as? String,
                   let imageUrl = data["imageUrl"] as? String {
                    recipeMap[name] = imageUrl  // 同じnameがあったら後のものが上書き
                }
            }
            // Step 2: mealsコレクションから userId に一致する記録を取得
            db.collection("meals")
                .whereField("userId", isEqualTo: currentUserId)
                .getDocuments { mealSnapshot, error in
                    if let error = error {
                        print("食事記録の取得エラー: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let mealDocs = mealSnapshot?.documents else { return }
                    
                    DispatchQueue.main.async {
                        self.cookingDataList = mealDocs.compactMap { doc in
                            let data = doc.data()
                            guard let name = data["name"] as? String,
                                  let timestamp = data["date"] as? Timestamp else {
                                return nil
                            }
                            
                            let date = timestamp.dateValue()
                            let imageUrl = recipeMap[name] ?? "https://via.placeholder.com/60"
                            
                            return CookingData(date: date, name: name, imageUrl: imageUrl)
                        }
                    }
                }
        }
    }
}

