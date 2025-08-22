import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn = false {
        didSet {
            if isLoggedIn {
                Task {
                    await loadUserProgress()
                }
            }
        }
    }
    @Published var errorMessage: String?
    @Published var isRegisterMode = false
    
    private let auth = AuthManager.shared
    
    init(){
        self.isLoggedIn = auth.isLoggedIn
        self.email = auth.currentEmail ?? ""
    }
    
    func login() {
        guard validateInputs() else { return }
        
        Task {
            do {
                try await auth.login(email: email, password: password)
                await MainActor.run {
                    isLoggedIn = true
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Ошибка входа: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func register() {
        guard validateInputs() else { return }
        
        Task {
            do {
                try await auth.register(email: email, password: password)
                await MainActor.run {
                    isLoggedIn = true
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Ошибка регистрации: \(error.localizedDescription)"
                }
            }
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
        auth.logout()
        isLoggedIn = false
        isRegisterMode = false
        email = ""      // очищаем email
        password = ""   // очищаем пароль
    }
    
    private func loadUserProgress() async {
        do {
            let records = try await UserService.shared.fetchProgress(email: email)
            ProgressManager.shared.saveProgress(for: email, progress: records)
            print("✅ Прогресс загружен с сервера для \(email)")
        } catch {
            print("❌ Ошибка загрузки прогресса: \(error)")
        }
    }
}
