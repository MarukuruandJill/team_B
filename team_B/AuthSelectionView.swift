import SwiftUI

struct AuthSelectionView: View {
    var body: some View {
        ZStack {
            Color(red: 0.89, green: 0.80, blue: 0.80) // #e3cdcd
                .ignoresSafeArea()
            Image("logo")
                .resizable()
                .frame(width: 370, height: 370)// アセット名を適宜変更
                .offset(x: 0, y: -100)
            Spacer()

            VStack(spacing: 20) {
                Spacer()
                NavigationLink(destination: RegisterView()) {
                    AuthButton(text: "新規登録")
                }

                NavigationLink(destination: LoginView()) {
                    AuthButton(text: "ログイン")
                }
                Spacer().frame(height: 80)
            }
        }
    }
}

struct AuthButton: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.title2)
            .padding()
            .frame(width: 220)
            .background(Color.brown)
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}
