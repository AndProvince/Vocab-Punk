//
//  ProfileView.swift
//  Vocab Punk
//
//  Created by Андрей on 23.07.2025.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var loginVM: LoginViewModel
    @Binding var selectedLanguage: String
    
    @State private var levels: [String: [String]] = [:]
    @State private var progressByLevel: [String: [String: Double]] = [:]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if loginVM.isLoggedIn {
                    // Верхняя карточка профиля
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(loginVM.email)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Menu {
                                ForEach(levels.keys.sorted(), id: \.self) { code in
                                    Button {
                                        selectedLanguage = code
                                    } label: {
                                        HStack {
                                            Image(LanguagesData.flags[code] ?? "flag")
                                                .resizable()
                                                .frame(width: 24, height: 16)
                                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                            
                                            Text(LanguagesData.names[code] ?? code)
                                        }
                                    }
                                }
                            } label: {
                                LanguageHeaderView(languageCode: selectedLanguage)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.15), Color.clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding([.horizontal, .top])
                    
                    // Список уровней
                    ScrollView {
                        LazyVStack {
                            if let languageLevels = levels[selectedLanguage] {
                                ForEach(languageLevels, id: \.self) { level in
                                    NavigationLink(
                                        destination: UserProgressView(
                                            flashcardsVM: FlashcardsViewModel(email: loginVM.email, lang: selectedLanguage, level: level)
                                        )
                                    ) {
                                        LevelProgressCardView(
                                            selectedLanguage: selectedLanguage,
                                            level: level,
                                            email: loginVM.email,
                                            progress: progressByLevel[selectedLanguage]?[level] ?? 0
                                        )
                                        .padding([.horizontal, .top])
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            } else {
                                Text("Словари не загружены")
                                    .foregroundColor(.gray)
                                    .padding(.top)
                            }
                        }
                    }
                    
                    // Кнопка выхода
                    Button(action: { loginVM.logout() }) {
                        Text("Выйти")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    
                } else {
                    VStack(spacing: 12) {
                        Text("Вы не вошли в систему")
                            .foregroundColor(.gray)
                            .padding()
                        
                        NavigationLink(destination: LoginView(viewModel: loginVM)) {
                            Text("Войти или зарегистрироваться")
                                .font(.body)
                                .underline()
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
            }
            .onAppear {
                levels = DictionaryManager.shared.availableLevels()
                refreshProgress()
            }
            .onChange(of: selectedLanguage) { _, _ in
                refreshProgress()
            }
//            .navigationTitle("Профиль")
        }
    }
    
    private func refreshProgress() {
        progressByLevel = ProgressManager.shared.averageProgressByLevel(email: loginVM.email)
    }
}
