import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Color(red: 0.89, green: 0.80, blue: 0.80) // #e3cdcd
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                TextField("メールアドレス", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                SecureField("パスワード", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button("ログイン") {
                    login()
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

    func login() {
        authViewModel.login(email: email, password: password) { success in
            if success {
                errorMessage = ""
                dismiss() // WelcomeView まで戻る → 自動で ContentView に切り替え
            } else {
                errorMessage = "ログインに失敗しました"
            }
        }
    }
}
