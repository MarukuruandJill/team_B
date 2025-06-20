//
//  MenuContent.swift
//  team_B
//
//  Created by 武井まりあ on 2025/06/11.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// フィルタ／ソート用データ
private let difficulties = ["すごく楽", "楽", "普通", "大変"]
private let categories = ["ご飯もの", "麺類", "肉料理", "魚料理", "野菜", "揚げ物", "鍋・スープ", "スイーツ", "その他"]

struct MenuRecipe: Identifiable {
    var id: String
    var name: String
    var imageUrl: String
    var difficulty: String
    var category: [String]
}

struct MenuContent: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showRegistration = false
    @State private var searchText = ""
    @State private var selectedSort = "手間がかからない順"
    private let sortOptions = ["手間がかからない順", "手間がかかる順"]
    @State private var selectedCategory: String? = nil // nil: 全て
    @State private var recipes: [MenuRecipe] = []

    // 検索・フィルタ・ソート適用後
    private var filteredRecipes: [MenuRecipe] {
        var list = recipes
        // 料理名検索
        if !searchText.isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        // カテゴリ絞り込み
        if let cat = selectedCategory {
            list = list.filter { $0.category.contains(cat) }
        }
        // ソート
        list.sort { a, b in
            let idxA = difficulties.firstIndex(of: a.difficulty) ?? 0
            let idxB = difficulties.firstIndex(of: b.difficulty) ?? 0
            return selectedSort == "手間がかからない順" ? (idxA < idxB) : (idxA > idxB)
        }
        return list
    }

    var body: some View {
        ZStack {
            // 背景色
            Color(red: 0.89, green: 0.80, blue: 0.80) // #e3cdcd
                .ignoresSafeArea()

            NavigationStack {
                VStack(spacing: 12) {
                    // 検索バー
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("料理名で検索", text: $searchText)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                    // ソート & カテゴリ
                    HStack {
                        Picker("並び順", selection: $selectedSort) {
                            ForEach(sortOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())

                        Spacer()

                        Picker("カテゴリ", selection: Binding(
                            get: { selectedCategory ?? "全て" },
                            set: { new in selectedCategory = (new == "全て" ? nil : new) }
                        )) {
                            Text("全て").tag("全て")
                            ForEach(categories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding(.horizontal)

                    // レシピ一覧
                    List(filteredRecipes) { recipe in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: recipe.imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    Color.gray
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                case .failure:
                                    Image(systemName: "photo").resizable().scaledToFit()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(recipe.name)
                                    .font(.headline)
                                Text(recipe.difficulty)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(PlainListStyle())
                }
                .overlay(
                    // プラスボタン
                    Button(action: { showRegistration = true }) {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.accentColor.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(), alignment: .bottomTrailing
                )
                .toolbar {
                    // 小さなログアウト
                    ToolbarItem(placement: .bottomBar) {
                        Button("ログアウト") {
                            authViewModel.logout()
                        }
                        .font(.footnote)
                    }
                }
                .padding(.top)
                .onAppear { fetchRecipes() }
                .navigationTitle("メニュー")
                .navigationDestination(isPresented: $showRegistration) {
                    RecordView()
                }
            }
        }
    }

    func fetchRecipes() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("recipes")
          .whereField("userId", isEqualTo: userId)
          .order(by: "createdAt", descending: true)
          .getDocuments { snapshot, error in
            if let error = error {
                print("データ取得エラー: \(error)")
                return
            }
            recipes = snapshot?.documents.compactMap { doc -> MenuRecipe? in
                let d = doc.data()
                guard
                    let name = d["name"] as? String,
                    let url = d["imageUrl"] as? String,
                    let diff = d["difficulty"] as? String,
                    let cats = d["category"] as? [String]
                else { return nil }
                return MenuRecipe(
                    id: doc.documentID,
                    name: name,
                    imageUrl: url,
                    difficulty: diff,
                    category: cats
                )
            } ?? []
          }
    }
}
