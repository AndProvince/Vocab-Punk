//
//  LoginView.swift
//  Vocab Punk
//
//  Created by Андрей on 23.07.2025.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.isRegisterMode ? "Регистрация" : "Вход")
                .font(.largeTitle)
                .padding(.bottom, 40)
            
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            SecureField("Пароль", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Button(action: {
                if viewModel.isRegisterMode {
                    viewModel.register()
                } else {
                    viewModel.login()
                }
            }) {
                Text(viewModel.isRegisterMode ? "Зарегистрироваться" : "Войти")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 20)
            
            Button(action: viewModel.toggleMode) {
                Text(viewModel.isRegisterMode ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Регистрация")
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
        }
        .padding()
        .onChange(of: viewModel.isLoggedIn) { _, newValue in
            if newValue {
                dismiss()
            }
        }
        .onChange(of: viewModel.isRegisterMode) { _, _ in
            viewModel.email = ""
            viewModel.password = ""
        }

    }
}
