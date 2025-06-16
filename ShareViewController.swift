import SwiftUI

struct RecipeShareView: View {
    @State private var shareURL: String = ""
    @State private var showingShareSheet = false
    
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
                        Text("共有リンクを入力")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                        
                        TextField("https://", text: $shareURL)
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
                
                // ボトムタブバー
                HStack {
                    TabBarButton(icon: "cup.and.saucer.fill", isSelected: false)
                    Spacer()
                    TabBarButton(icon: "calendar", isSelected: false)
                    Spacer()
                    TabBarButton(icon: "square.and.arrow.up", isSelected: true)
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 20)
                .background(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: -2)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func addRecipeDeck() {
        // レシピデッキ追加の処理
        print("レシピデッキを追加: \(shareURL)")
        // ここに実際の処理を実装
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {
            // タブ切り替えの処理
        }) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .black : .gray)
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
