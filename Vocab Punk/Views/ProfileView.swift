//
//  ProfileView.swift
//  Vocab Punk
//
//  Created by Андрей on 23.07.2025.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @Binding var selectedLanguage: String
    
    @State private var levels: [String: [String]] = [:]
    @State private var progressByLevel: [String: [String: Double]] = [:]
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if loginViewModel.isLoggedIn {
                    profileHeader
                    levelList
                    actionButtons
                } else {
                    notLoggedInView
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
        }
    }

    // MARK: - Подкомпоненты

    private var profileHeader: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(loginViewModel.email)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                languageMenu
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
    }

    private var languageMenu: some View {
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

    private var levelList: some View {
        ScrollView {
            LazyVStack {
                if let languageLevels = levels[selectedLanguage] {
                    ForEach(languageLevels, id: \.self) { level in
                        NavigationLink(
                            destination: UserProgressView(
                                flashcardsVM: FlashcardsViewModel(loginViewModel: loginViewModel, lang: selectedLanguage, level: level)
                            )
                        ) {
                            LevelProgressCardView(
                                selectedLanguage: selectedLanguage,
                                level: level,
                                email: loginViewModel.email,
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
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
//            Button {
//                showResetConfirmation = true
//            } label: {
//                Text("Сбросить")
//            }
//            .modifier(ProfileButtonStyle(
//                backgroundColor: Color.red.opacity(0.15),
//                foregroundColor: .red
//            ))
//            .alert("Вы уверены?", isPresented: $showResetConfirmation) {
//                Button("Сбросить", role: .destructive) {
//                    ProgressManager.shared.clearCache(for: loginViewModel.email, removeData: true)
//                    refreshProgress()
//                }
//                Button("Отмена", role: .cancel) { }
//            } message: {
//                Text("Это действие удалит весь ваш прогресс обучения и его нельзя будет отменить.")
//            }
            
            Button {
                loginViewModel.logout()
            } label: {
                Text("Выйти")
            }
            .modifier(ProfileButtonStyle(
                backgroundColor: Color.gray.opacity(0.15),
                foregroundColor: .red
            ))
        }
        .padding(.horizontal)
    }

    private var notLoggedInView: some View {
        VStack(spacing: 12) {
            Text("Вы не вошли в систему")
                .foregroundColor(.gray)
                .padding()
            
            NavigationLink(destination: LoginView(viewModel: loginViewModel)) {
                Text("Войти или зарегистрироваться")
                    .font(.body)
                    .underline()
                    .foregroundColor(.blue)
            }
        }
    }

    // MARK: - Логика

    private func refreshProgress() {
        progressByLevel = ProgressManager.shared.averageProgressByLevel(email: loginViewModel.email)
    }
}
