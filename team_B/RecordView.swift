import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import FirebaseAuth

struct RecordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dishName: String = ""
    @State private var selectedDifficulty: String = "普通"
    @State private var selectedCategories: Set<String> = []
    @State private var url: String = ""
    @State private var memo: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isPickerPresented = false

    private let difficulties = ["すごく楽", "楽", "普通", "大変"]
    private let categories = ["ご飯もの", "麺類", "肉料理", "魚料理", "野菜", "揚げ物", "鍋・スープ", "スイーツ", "その他"]
    private let pastelColors: [Color] = [
        Color(red: 1.00, green: 0.90, blue: 0.80),
        Color(red: 0.85, green: 0.95, blue: 0.80),
        Color(red: 0.95, green: 0.85, blue: 1.00),
        Color(red: 0.80, green: 0.90, blue: 1.00),
        Color(red: 1.00, green: 0.80, blue: 0.90),
        Color(red: 1.00, green: 0.95, blue: 0.80)
    ]

    var body: some View {
        ZStack {
            // 背景色 #e3cdcd
            Color(red: 0.89, green: 0.80, blue: 0.80)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダーの閉じるボタン
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding()
                    }
                    Spacer()
                }
                .background(Color(red: 0.89, green: 0.80, blue: 0.80))

                // タイトルピル
                HStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Text("料理を記録")
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(20)
                    Spacer()
                }
                .padding(.bottom, 16)
                .background(Color(red: 0.89, green: 0.80, blue: 0.80))

                // フォーム部分
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 24) {
                        // 料理名入力
                        Group {
                            Text("料理名")
                                .font(.headline)
                                .padding(.horizontal)
                            TextField("例: オムライス", text: $dishName)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }

                        // 難易度選択
                        Group {
                            Text("大変さ")
                                .font(.headline)
                                .padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(difficulties, id: \ .self) { diff in
                                        let selected = selectedDifficulty == diff
                                        Text(diff)
                                            .font(.subheadline)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(selected ? Color.accentColor : Color.white)
                                            .foregroundColor(selected ? .white : .black)
                                            .cornerRadius(16)
                                            .onTapGesture { selectedDifficulty = diff }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // カテゴリ選択
                        Group {
                            Text("カテゴリ")
                                .font(.headline)
                                .padding(.horizontal)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                                ForEach(Array(categories.enumerated()), id: \ .offset) { idx, cat in
                                    let selected = selectedCategories.contains(cat)
                                    Text(cat)
                                        .font(.subheadline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(selected ? pastelColors[idx % pastelColors.count] : Color.white)
                                        .foregroundColor(.black)
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
                            .padding(.horizontal)
                        }

                        // 画像選択
                        Group {
                            Text("画像")
                                .font(.headline)
                                .padding(.horizontal)
                            if let img = selectedImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(16)
                                    .padding(.horizontal)
                            } else {
                                Button(action: { isPickerPresented = true }) {
                                    Text("画像を選択")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                }
                                .padding(.horizontal)
                                .sheet(isPresented: $isPickerPresented) {
                                    PhotoPicker(selectedImage: $selectedImage)
                                }
                            }
                        }

                        // URL入力
                        TextField("https://", text: $url)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        // メモ入力
                        Group {
                            Text("メモ")
                                .font(.headline)
                                .padding(.horizontal)
                            TextEditor(text: $memo)
                                .frame(height: 120)
                                .padding(.horizontal)
                                .background(Color.white)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.vertical)
                }

                // 記録ボタン
                Button(action: { saveToFirestore() }) {
                    Text("この料理を記録する")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.90, green: 0.40, blue: 0.50))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)

            }
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
