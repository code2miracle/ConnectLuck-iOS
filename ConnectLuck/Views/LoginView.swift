//
//  LoginView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel = UserViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showSignup = false
    @State private var showForgotPassword = false
    @State private var isLoading = false
    @EnvironmentObject private var userState: UserState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 로고
                    Image("ConnectLuckLogo") // 로고 이미지 필요
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                        .padding(.top, 40)
                    
                    // 환영 텍스트
                    Text("Connect Luck에 오신 것을 환영합니다")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("로그인하고 서비스를 이용해보세요")
                        .font(.system(size: 16))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    // 로그인 폼
                    VStack(spacing: 16) {
                        // 이메일 입력
                        VStack(alignment: .leading, spacing: 8) {
                            Text("이메일")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(CLColor.SwiftUI.textPrimary)
                            
                            TextField("이메일 주소 입력", text: $email)
                                .font(.system(size: 17))
                                .padding(16)
                                .background(CLColor.SwiftUI.surface)
                                .cornerRadius(8)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // 비밀번호 입력
                        VStack(alignment: .leading, spacing: 8) {
                            Text("비밀번호")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(CLColor.SwiftUI.textPrimary)
                            
                            SecureField("비밀번호 입력", text: $password)
                                .font(.system(size: 17))
                                .padding(16)
                                .background(CLColor.SwiftUI.surface)
                                .cornerRadius(8)
                        }
                        
                        // 비밀번호 찾기
                        HStack {
                            Spacer()
                            Button {
                                showForgotPassword = true
                            } label: {
                                Text("비밀번호를 잊으셨나요?")
                                    .font(.system(size: 14))
                                    .foregroundColor(CLColor.SwiftUI.primaryColor)
                            }
                        }
                        
                        // 로그인 버튼
                        PrimaryButton(text: "로그인") {
                            login()
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                        .opacity((email.isEmpty || password.isEmpty || isLoading) ? 0.6 : 1)
                        
                        // 회원가입 링크
                        HStack {
                            Text("아직 계정이 없으신가요?")
                                .font(.system(size: 14))
                                .foregroundColor(CLColor.SwiftUI.textSecondary)
                            
                            Button {
                                showSignup = true
                            } label: {
                                Text("회원가입")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(CLColor.SwiftUI.primaryColor)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .background(CLColor.SwiftUI.backgroundBase)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showSignup) {
                SignUpView()
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(width: 100, height: 100)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("로그인 실패"),
                    message: Text(viewModel.errorMessage ?? "오류가 발생했습니다."),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
    
    private func login() {
        isLoading = true
        
        Task {
            let success = await viewModel.login(email: email, password: password)
            if success {
                userState.isLoggedIn = true
            }
            isLoading = false
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
