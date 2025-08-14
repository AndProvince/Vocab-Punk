//
//  AdminPanelView.swift
//  Vocab Punk
//
//  Created by Андрей on 23.07.2025.
//

import SwiftUI

struct AdminPanelView: View {
    @State private var users: [String] = []
    
    @State private var activeAlert: ActiveAlert? = nil
    
    enum ActiveAlert {
        case resetDictionary
        case resetProgress
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if users.isEmpty {
                    Text("Пользователей нет")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        Section(header: Text("Зарегистрированные пользователи")) {
                            ForEach(users, id: \.self) { email in
                                HStack {
                                    Text(email)
                                    Spacer()
                                    Button("Удалить") {
                                        AuthManager.shared.deleteCredentials(email: email)
                                        loadUsers()
                                    }
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: {
                        activeAlert = .resetDictionary
                        DictionaryManager.shared.clearCache(removeFiles: true)
                    }) {
                        Text("Очистить кэш словарей")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        activeAlert = .resetProgress
                    }) {
                        Text("Сбросить прогресс обучения")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .onAppear(perform: loadUsers)
            .navigationTitle("Администрирование")
            .alert(item: $activeAlert) { alertType in
                switch alertType {
                case .resetDictionary:
                    return Alert(
                        title: Text("Подтверждение"),
                        message: Text("Вы уверены, что хотите очистить кэш словарей?"),
                        primaryButton: .destructive(Text("Очистить")) {
                            DictionaryManager.shared.clearCache(removeFiles: true)
//                            let _ = DictionaryManager.shared.loadDictionary(lang: selectedLanguage, level: "A1")
                        },
                        secondaryButton: .cancel()
                    )
                case .resetProgress:
                    return Alert(
                        title: Text("Подтверждение"),
                        message: Text("Вы уверены, что хотите сбросить прогресс обучения у всех пользователей?"),
                        primaryButton: .destructive(Text("Сбросить")) {
                            resetAllProgress()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
    
    private func loadUsers() {
        users = AuthManager.shared.getAllUsers()
        print("users loaded")
    }
    
    private func resetAllProgress() {
        for user in users {
            ProgressManager.shared.saveProgress(for: user, progress: [:])
        }
    }
}

// MARK: - ActiveAlert + Identifiable
extension AdminPanelView.ActiveAlert: Identifiable {
    var id: String {
        switch self {
        case .resetDictionary: return "resetDictionary"
        case .resetProgress: return "resetProgress"
        }
    }
}
