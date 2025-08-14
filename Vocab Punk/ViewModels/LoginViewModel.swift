import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    @Published var isRegisterMode = false
    
    private let auth = AuthManager.shared
    
    init(){
        if let currentUser = AuthManager.shared.getCurrentUser() {
            email = currentUser
            isLoggedIn = true
        }
    }
    
    func login() {
        guard validateInputs() else { return }
        
        if auth.authenticate(email: email, password: password) {
            isLoggedIn = true
            errorMessage = nil
//            print("Вход выполнен с email: \(email), пароль: \(password)")
        } else {
            errorMessage = "Неверный email или пароль"
        }
    }
    
    func register() {
        guard validateInputs() else { return }
        
        if auth.register(email: email, password: password) {
            isLoggedIn = true
            errorMessage = nil
//            print("Регистрация с email: \(email), пароль: \(password)")
        } else {
            errorMessage = "Пользователь с таким email уже существует"
        }
    }
    
    func toggleMode() {
        isRegisterMode.toggle()
        errorMessage = nil
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = #"^\S+@\S+\.\S+$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    private func validateInputs() -> Bool {
        if !isValidEmail(email) {
            errorMessage = "Некорректный email"
            return false
        }
        if password.count < 8 {
            errorMessage = "Пароль должен содержать не менее 8 символов"
            return false
        }
        return true
    }
    
    func logout() {
        isLoggedIn = false
        email = ""      // очищаем email
        password = ""   // очищаем пароль
        AuthManager.shared.deleteCurrentUser()
    }
}
