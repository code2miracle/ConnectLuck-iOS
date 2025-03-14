//
//  SignUpView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = UserViewModel()
    
    // 회원가입 입력 필드
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var phoneNumber = ""
    
    // 유효성 검사 상태
    @State private var isEmailValid = false
    @State private var isEmailChecked = false
    @State private var isPasswordValid = false
    @State private var isPasswordMatch = false
    @State private var isNameValid = false
    @State private var isPhoneValid = false
    
    @State private var isLoading = false
    @State private var showTermsAgreement = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 회원가입 입력 폼
                    VStack(spacing: 16) {
                        // 이메일 입력
                        VStack(alignment: .leading, spacing: 8) {
                            Text("이메일")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(CLColor.SwiftUI.textPrimary)
                            
                            HStack {
                                TextField("example@email.com", text: $email)
                                    .font(.system(size: 17))
                                    .padding(16)
                                    .background(CLColor.SwiftUI.surface)
                                    .cornerRadius(8)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .onChange(of: email) { _, _ in
                                        isEmailChecked = false
                                        validateEmail()
                                    }
                                
                                Button {
                                    checkEmailAvailability()
                                } label: {
                                    Text("중복확인")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(isEmailValid ? CLColor.SwiftUI.primaryColor : CLColor.SwiftUI.textSecondary)
                                        .cornerRadius(6)
                                }
                                .disabled(!isEmailValid)
                            }
                            
                            // 이메일 유효성 메시지
                            if !email.isEmpty {
                                if isEmailValid {
                                    if isEmailChecked {
                                        Text("사용 가능한 이메일입니다.")
                                            .font(.system(size: 12))
                                            .foregroundColor(CLColor.SwiftUI.success)
                                    }
                                } else {
                                    Text("올바른 이메일 형식을 입력해주세요.")
                                        .font(.system(size: 12))
                                        .foregroundColor(CLColor.SwiftUI.error)
                                }
                            }
                        }
                        
                        // 비밀번호 입력
                        VStack(alignment: .leading, spacing: 8) {
                            Text("비밀번호")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(CLColor.SwiftUI.textPrimary)
                            
                            SecureField("8자 이상 입력해주세요", text: $password)
                                .font(.system(size: 17))
                                .padding(16)
                                .background(CLColor.SwiftUI.surface)
                                .cornerRadius(8)
                                .onChange(of: password) { _, _ in
                                    validatePassword()
                                    validatePasswordMatch()
                                }
                            
                            // 비밀번호 유효성 메시지
                            if !password.isEmpty && !isPasswordValid {
                                Text("비밀번호는 8자 이상이어야 합니다.")
                                    .font(.system(size: 12))
                                    .foregroundColor(CLColor.SwiftUI.error)
                            }
                        }
                        
                        // 비밀번호 확인
                        VStack(alignment: .leading, spacing: 8) {
                            Text("비밀번호 확인")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(CLColor.SwiftUI.textPrimary)
                            
                            SecureField("비밀번호를 다시 입력해주세요", text: $confirmPassword)
                                .font(.system(size: 17))
                                .padding(16)
                                .background(CLColor.SwiftUI.surface)
                                .cornerRadius(8)
                                .onChange(of: confirmPassword) { _, _ in
                                    validatePasswordMatch()
                                }
                            
                            // 비밀번호 확인 메시지
                            if !confirmPassword.isEmpty {
                                if isPasswordMatch {
                                    Text("비밀번호가 일치합니다.")
                                        .font(.system(size: 12))
                                        .foregroundColor(CLColor.SwiftUI.success)
                                } else {
                                    Text("비밀번호가 일치하지 않습니다.")
                                        .font(.system(size: 12))
                                        .foregroundColor(CLColor.SwiftUI.error)
                                }
                            }
                        }
                        
                        // 이름 입력
                        VStack(alignment: .leading, spacing: 8) {
                            Text("이름")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(CLColor.SwiftUI.textPrimary)
                            
                            TextField("이름을 입력해주세요", text: $name)
                                .font(.system(size: 17))
                                .padding(16)
                                .background(CLColor.SwiftUI.surface)
                                .cornerRadius(8)
                                .onChange(of: name) { _, _ in
                                    isNameValid = !name.isEmpty
                                }
                        }
                        
                        // 전화번호 입력
                        VStack(alignment: .leading, spacing: 8) {
                            Text("전화번호")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(CLColor.SwiftUI.textPrimary)
                            
                            TextField("'-' 없이 입력해주세요", text: $phoneNumber)
                                .font(.system(size: 17))
                                .padding(16)
                                .background(CLColor.SwiftUI.surface)
                                .cornerRadius(8)
                                .keyboardType(.numberPad)
                                .onChange(of: phoneNumber) { _, _ in
                                    validatePhone()
                                }
                            
                            // 전화번호 유효성 메시지
                            if !phoneNumber.isEmpty && !isPhoneValid {
                                Text("올바른 전화번호 형식을 입력해주세요.")
                                    .font(.system(size: 12))
                                    .foregroundColor(CLColor.SwiftUI.error)
                            }
                        }
                        
                        // 이용약관 동의
                        Button {
                            showTermsAgreement = true
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.square")
                                    .foregroundColor(CLColor.SwiftUI.primaryColor)
                                
                                Text("이용약관 및 개인정보 처리방침에 동의합니다")
                                    .font(.system(size: 14))
                                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                                
                                Spacer()
                            }
                        }
                        
                        // 회원가입 버튼
                        PrimaryButton(text: "회원가입") {
                            signUp()
                        }
                        .disabled(!isFormValid())
                        .opacity(isFormValid() ? 1 : 0.6)
                        
                        // 로그인 화면으로 돌아가기
                        Button {
                            dismiss()
                        } label: {
                            Text("이미 계정이 있으신가요? 로그인하기")
                                .font(.system(size: 14))
                                .foregroundColor(CLColor.SwiftUI.primaryColor)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
            .background(CLColor.SwiftUI.backgroundBase)
            .navigationTitle("회원가입")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(CLColor.SwiftUI.textPrimary)
                    }
                }
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
                    title: Text("회원가입 실패"),
                    message: Text(viewModel.errorMessage ?? "오류가 발생했습니다."),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
    
    // 이메일 유효성 검사
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        isEmailValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // 이메일 중복 확인
    private func checkEmailAvailability() {
        isLoading = true
        
        Task {
            let isAvailable = try? await viewModel.checkEmailAvailability(email: email)
            isEmailChecked = isAvailable ?? false
            isLoading = false
        }
    }
    
    // 비밀번호 유효성 검사
    private func validatePassword() {
        isPasswordValid = password.count >= 8
    }
    
    // 비밀번호 확인 검사
    private func validatePasswordMatch() {
        isPasswordMatch = !confirmPassword.isEmpty && password == confirmPassword
    }
    
    // 전화번호 유효성 검사
    private func validatePhone() {
        let phoneRegex = "^01([0|1|6|7|8|9])([0-9]{7,8})$"
        isPhoneValid = NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phoneNumber)
    }
    
    // 폼 전체 유효성 검사
    private func isFormValid() -> Bool {
        return isEmailValid && isEmailChecked && isPasswordValid && isPasswordMatch && isNameValid && isPhoneValid
    }
    
    // 회원가입 수행
    private func signUp() {
        isLoading = true
        
        Task {
            if await viewModel.signup(email: email, password: password, name: name, phoneNumber: phoneNumber) {
                isLoading = false
                dismiss() // 성공 시 로그인 화면으로 돌아가기
            } else {
                isLoading = false
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
