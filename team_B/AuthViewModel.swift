import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        // 起動時にログイン済か確認
        self.isLoggedIn = Auth.auth().currentUser != nil
    }

    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if result != nil {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if result != nil {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        self.isLoggedIn = false
    }
}
