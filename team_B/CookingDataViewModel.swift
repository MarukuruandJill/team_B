import FirebaseFirestore

class CookingDataViewModel: ObservableObject {
    @Published var cookingDataList: [CookingData] = []
    
    func fetchCookingData() {
        let db = Firestore.firestore()
        
        // まずrecipesコレクションからレシピ名と画像URLの辞書を作成
        db.collection("recipes").getDocuments { recipeSnapshot, error in
            if let error = error {
                print("Error fetching recipes: \(error.localizedDescription)")
                return
            }
            
            guard let recipeDocs = recipeSnapshot?.documents else { return }
            
            // 明示的に戻り値の型を指定して辞書作成
            let recipeMap: [String: String] = Dictionary(uniqueKeysWithValues:
                                                            recipeDocs.compactMap { doc -> (String, String)? in
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let imageUrl = data["imageUrl"] as? String else {
                    return nil
                }
                return (name, imageUrl)
            }
            )
            
            // 次にmealsコレクションから実際の記録を取得
            db.collection("meals").getDocuments { mealSnapshot, error in
                if let error = error {
                    print("Error fetching meals: \(error.localizedDescription)")
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
                        // recipeMapに無ければプレースホルダー画像URLをセット
                        let imageUrl = recipeMap[name] ?? "https://via.placeholder.com/60"
                        
                        return CookingData(date: date, name: name, imageUrl: imageUrl)
                    }
                }
            }
        }
    }
}
