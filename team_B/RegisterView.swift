import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var errorMessage = ""

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.89, green: 0.80, blue: 0.80) // #e3cdcd
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                TextField("ユーザー名", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                TextField("メールアドレス", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                SecureField("パスワード", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button("新規登録") {
                    register()
                }
                .font(.title2)
                .padding()
                .frame(width: 220)
                .background(Color.brown)
                .foregroundColor(.white)
                .cornerRadius(12)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
        }
    }

    func register() {
        authViewModel.register(email: email, password: password) { success in
            if success, let uid = Auth.auth().currentUser?.uid {
                // Firestore にユーザー情報を保存
                let db = Firestore.firestore()
                db.collection("users").document(uid).setData([
                    "username": username,
                    "email": email,
                    "createdAt": Timestamp()
                ]) { error in
                    if let error = error {
                        errorMessage = "Firestore保存失敗: \(error.localizedDescription)"
                    } else {
                        errorMessage = ""
                        dismiss() 
                    }
                }
            } else {
                errorMessage = "登録に失敗しました"
            }
        }
    }
}

