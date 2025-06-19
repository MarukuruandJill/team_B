import SwiftUI
import FirebaseAuth

struct WelcomeView: View {
    @State private var navigateToAuth = false
    
    var body: some View {
        ZStack {
            Color(red: 0.89, green: 0.80, blue: 0.80) // #e3cdcd
                .ignoresSafeArea()
            Image("logo")
                .resizable()
                .frame(width: 370, height: 370)// アセット名を適宜変更
            Spacer()
            
            
            VStack {
                Spacer()
                
                Button(action: {
                    navigateToAuth = true
                }) {
                    Text("はじめる")
                        .font(.title2)
                        .padding()
                        .frame(width: 220)
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.bottom, 60)
                
            }
            .navigationDestination(isPresented: $navigateToAuth) {
                nextView()
            }
        }
    }
    @ViewBuilder
        func nextView() -> some View {
            if Auth.auth().currentUser != nil {
                ContentView()
            } else {
                AuthSelectionView()
            }
        }
}

