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
    @State var userState: UserState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 로고
                    VStack(spacing: 12) {
                        Image(systemName: "hands.sparkles.fill")
                            .font(.system(size: 60))
                            .foregroundColor(CLColor.SwiftUI.primaryColor)
                            .padding(.top, 40)
                        
                        Text("Connect Luck")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(CLColor.SwiftUI.textPrimary)
                        
                        Text("푸드트럭과 행사를 연결하는 플랫폼")
                            .font(.system(size: 16))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                            .padding(.top, 4)
                    }
                    
                    // 환영 텍스트
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
                    .padding(.top, 16)
                    
                    // 소셜 로그인 - 추후 구현 예정
                    VStack(spacing: 16) {
                        Text("또는")
                            .font(.system(size: 14))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                            .padding(.vertical, 8)
                        
                        socialLoginButtons
                    }
                    .padding(.top, 24)
                    
                    // 게스트로 둘러보기
                    Button {
                        // 메인 화면으로 이동 (로그인 없이)
                        // 2단계에서 구현 예정
                    } label: {
                        Text("게스트로 둘러보기")
                            .font(.system(size: 16))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                            .padding(.vertical, 12)
                    }
                    .padding(.top, 24)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(CLColor.SwiftUI.backgroundBase)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showSignup) {
                SignUpView(userState: userState)
            }
            .sheet(isPresented: $showForgotPassword) {
                FindAccountView()
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
    
    // 소셜 로그인 버튼들
    private var socialLoginButtons: some View {
        VStack(spacing: 12) {
            Button {
                // 카카오 로그인 기능 - 추후 구현
            } label: {
                HStack {
                    Image(systemName: "message.fill")
                        .foregroundColor(.black)
                    
                    Text("카카오로 시작하기")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.yellow)
                .cornerRadius(8)
            }
            
            Button {
                // 네이버 로그인 기능 - 추후 구현
            } label: {
                HStack {
                    Image(systemName: "n.square.fill")
                        .foregroundColor(.white)
                    
                    Text("네이버로 시작하기")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.green)
                .cornerRadius(8)
            }
            
            Button {
                // 구글 로그인 기능 - 추후 구현
            } label: {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .foregroundColor(.white)
                    
                    Text("Google로 시작하기")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red)
                .cornerRadius(8)
            }
        }
    }
    
    // 로그인 기능
    private func login() {
        isLoading = true
        
        Task {
            let success = await viewModel.login(email: email, password: password)
            if success {
                userState.isLoggedIn = true
                userState.currentUser = viewModel.currentUser
            }
            isLoading = false
        }
    }
}

// 임시 계정 찾기 화면 (추후 구현 예정)
struct FindAccountView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("계정 찾기")
                    .font(.title)
                    .padding()
                
                Text("이 기능은 2단계에서 구현 예정입니다.")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("계정 찾기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView(userState: UserState())
}
