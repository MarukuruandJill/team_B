import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import FirebaseAuth

struct RecordView: View {
    @State private var dishName: String = ""
    @State private var selectedDifficulty: String = "普通"
    @State private var selectedCategories: Set<String> = []
    @State private var url: String = ""
    @State private var memo: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isPickerPresented = false
    
    private let difficulties = ["すごく楽", "楽", "普通", "大変"]
    private let categories = ["和食", "洋食", "中華", "韓国", "海外の料理", "野菜", "海鮮", "揚げ物", "鍋・スープ", "その他"]
    
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
                        
                        // 画像
                        Group {
                            Text("画像")
                                .font(.headline)
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(8)
                            } else {
                                Button("画像を選択") {
                                    isPickerPresented = true
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .sheet(isPresented: $isPickerPresented) {
                            PhotoPicker(selectedImage: $selectedImage)
                        }
                        
                        // URL
                        TextField("https://", text: $url)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                        
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
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーIDが取得できませんでした")
            return
        }
        
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        if let selectedImage = selectedImage, let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            let imageRef = storage.reference().child("images/\(UUID().uuidString).jpg")
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("画像アップロード失敗: \(error.localizedDescription)")
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("画像URL取得失敗: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let imageUrl = url?.absoluteString else { return }
                    
                    let newRecipe: [String: Any] = [
                        "name": dishName,
                        "difficulty": selectedDifficulty,
                        "category": Array(selectedCategories),
                        "recipeUrl": self.url,
                        "memo": memo,
                        "createdAt": Timestamp(),
                        "imageUrl": imageUrl,
                        "userId": userId
                    ]
                    
                    db.collection("recipes").addDocument(data: newRecipe) { error in
                        if let error = error {
                            print("保存失敗: \(error.localizedDescription)")
                        } else {
                            print("保存成功！")
                            dishName = ""
                            selectedDifficulty = "普通"
                            selectedCategories = []
                            self.url = ""
                            memo = ""
                            self.selectedImage = nil
                        }
                    }
                }
            }
        } else {
            print("画像が選択されていません")
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}

// プレビュー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}
