//
//  FlashcardsSetsView.swift
//  Vocab Punk
//
//  Created by Андрей on 23.07.2025.
//

import SwiftUI

struct FlashcardsSetsView: View {
    @State private var isShowingProfile = false
    @State private var selectedLevel: IdentifiableString? = nil
    @State private var selectedLanguage = "EN" // текущий язык
    @State private var showLanguageMenu = false

    @StateObject private var loginViewModel = LoginViewModel()
    @ObservedObject private var updateService = DictionaryUpdateService.shared
    @ObservedObject private var fsViewModel = FlashcardsSetsViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if loginViewModel.isLoggedIn {
                    ScrollView {
                        if let languageLevels = fsViewModel.levels[selectedLanguage] {
                            VStack(spacing: 16) {
                                ForEach(languageLevels, id: \.self) { level in
                                    LevelSelectButton(level: level) {
                                        selectedLevel = IdentifiableString(value: level)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.top, 20)
                        }
                        else {
                            VStack(spacing: 12) {
                                Text("Словари не загружены")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Text("Войдите в профиль, чтобы начать изучение.")
                            .foregroundColor(.gray)
                            .padding()

                        Button(action: {
                            isShowingProfile = true
                        }) {
                            Text("Войти или зарегистрироваться")
                                .font(.body)
                                .underline()
                                .foregroundColor(.blue)
                        }
                    }
                }

                Spacer()
                
                Text("v.\(updateService.localVersion ?? "-")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .navigationBarItems(
                leading:
                    Menu {
                        ForEach(fsViewModel.levels.keys.sorted(), id: \.self) { code in
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
                        Image(LanguagesData.flags[selectedLanguage] ?? "flag")
                            .resizable()
                            .frame(width: 30, height: 20)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
                    }
                ,
                trailing:	
                    Button(action: {
                        isShowingProfile = true
                    }) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }
            )
            .sheet(item: $selectedLevel) { item in
                FlashcardsView(
                    viewModel: FlashcardsViewModel(email: loginViewModel.email, lang: selectedLanguage, level: item.value)
                )
            }
            .sheet(isPresented: $isShowingProfile) {
                if loginViewModel.isLoggedIn {
                    ProfileView(loginVM: loginViewModel, selectedLanguage: $selectedLanguage)
                } else {
                    LoginView(viewModel: loginViewModel)
                }
            }
        }
    }
}
