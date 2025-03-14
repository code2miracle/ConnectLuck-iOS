//
//  ProfileView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userState: UserState
    @State private var showRoleSelectionSheet = false
    
    var body: some View {
        NavigationView {
            if userState.isLoggedIn {
                List {
                    // 기본 프로필 정보
                    Section {
                        HStack(spacing: 16) {
                            // 프로필 이미지 (또는 기본 아이콘)
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(CLColor.SwiftUI.primaryColor)
                            
                            // 사용자 정보
                            VStack(alignment: .leading, spacing: 4) {
                                if let user = userState.currentUser {
                                    Text(user.name)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                                    
                                    Text(user.email)
                                        .font(.system(size: 14))
                                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                                    
                                    // 사용자 역할 표시
                                    HStack {
                                        if userState.isAdmin {
                                            RoleBadge(text: "관리자")
                                        }
                                        if userState.isFoodTruckManager {
                                            RoleBadge(text: "푸드트럭 사업자")
                                        }
                                        if userState.isEventManager {
                                            RoleBadge(text: "행사 관계자")
                                        }
                                    }
                                    .padding(.top, 4)
                                } else {
                                    Text("사용자 정보 로딩 중...")
                                        .font(.system(size: 18))
                                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // 사용자 역할
                    Section(header: Text("역할 관리")) {
                        if !userState.isFoodTruckManager {
                            Button {
                                showRoleSelectionSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "car")
                                        .foregroundColor(CLColor.SwiftUI.primaryColor)
                                    
                                    Text("푸드트럭 사업자 등록")
                                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                                }
                            }
                        }
                        
                        if !userState.isEventManager {
                            Button {
                                showRoleSelectionSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(CLColor.SwiftUI.primaryColor)
                                    
                                    Text("행사 관계자 등록")
                                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                                }
                            }
                        }
                    }
                    
                    // 계정 관리
                    Section(header: Text("계정 관리")) {
                        // 내 정보 수정
                        NavigationLink(destination: Text("내 정보 수정")) {
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(CLColor.SwiftUI.primaryColor)
                                
                                Text("내 정보 수정")
                                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                            }
                        }
                        
                        // 비밀번호 변경
                        NavigationLink(destination: Text("비밀번호 변경")) {
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(CLColor.SwiftUI.primaryColor)
                                
                                Text("비밀번호 변경")
                                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                            }
                        }
                    }
                    
                    // 앱 정보
                    Section(header: Text("앱 정보")) {
                        // 공지사항
                        NavigationLink(destination: Text("공지사항")) {
                            HStack {
                                Image(systemName: "megaphone")
                                    .foregroundColor(CLColor.SwiftUI.primaryColor)
                                
                                Text("공지사항")
                                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                            }
                        }
                        
                        // 이용약관
                        NavigationLink(destination: Text("이용약관")) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(CLColor.SwiftUI.primaryColor)
                                
                                Text("이용약관")
                                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                            }
                        }
                        
                        // 개인정보 처리방침
                        NavigationLink(destination: Text("개인정보 처리방침")) {
                            HStack {
                                Image(systemName: "shield")
                                    .foregroundColor(CLColor.SwiftUI.primaryColor)
                                
                                Text("개인정보 처리방침")
                                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                            }
                        }
                    }
                    
                    // 로그아웃 버튼
                    Section {
                        Button {
                            userState.logout()
                        } label: {
                            HStack {
                                Spacer()
                                Text("로그아웃")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("마이페이지")
                .sheet(isPresented: $showRoleSelectionSheet) {
                    RoleSelectionView()
                }
            } else {
                // 로그인 안 된 상태
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 70))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                    
                    Text("로그인이 필요합니다")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                    
                    Text("로그인하고 더 많은 기능을 이용해보세요.")
                        .font(.system(size: 16))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    PrimaryButton(text: "로그인") {
                        // 로그인 화면으로 이동
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("마이페이지")
            }
        }
    }
}

// 역할 배지 컴포넌트
struct RoleBadge: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(CLColor.SwiftUI.primaryColor.opacity(0.1))
            .foregroundColor(CLColor.SwiftUI.primaryColor)
            .cornerRadius(12)
    }
}

// 역할 선택 뷰
struct RoleSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userState: UserState
    @State private var selectedRole: UserRole?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("역할을 선택해주세요")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .padding(.top, 24)
                
                VStack(spacing: 16) {
                    // 푸드트럭 사업자 역할 선택
                    if !userState.isFoodTruckManager {
                        Button {
                            selectedRole = .foodTruckManager
                        } label: {
                            RoleCard(
                                icon: "car.fill",
                                title: "푸드트럭 사업자",
                                description: "행사에 참가 신청하고 메뉴를 관리할 수 있습니다.",
                                isSelected: selectedRole == .foodTruckManager
                            )
                        }
                    }
                    
                    // 행사 관계자 역할 선택
                    if !userState.isEventManager {
                        Button {
                            selectedRole = .eventManager
                        } label: {
                            RoleCard(
                                icon: "calendar",
                                title: "행사 관계자",
                                description: "행사를 등록하고 푸드트럭 참가를 관리할 수 있습니다.",
                                isSelected: selectedRole == .eventManager
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                // 등록 버튼
                PrimaryButton(text: "역할 등록하기") {
                    addRole()
                }
                .disabled(selectedRole == nil || isLoading)
                .opacity(selectedRole == nil || isLoading ? 0.6 : 1)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(CLColor.SwiftUI.backgroundBase)
            .navigationTitle("역할 등록")
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
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("역할 등록 실패"),
                    message: Text(errorMessage ?? "오류가 발생했습니다."),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
    
    private func addRole() {
        guard let role = selectedRole else { return }
        
        isLoading = true
        
        Task {
            do {
                let userViewModel = UserViewModel()
                if await userViewModel.addRole(role: role) {
                    // 성공 시 UserState 업데이트
                    await userState.fetchUserInfo()
                    isLoading = false
                    dismiss()
                } else {
                    // 실패 시 에러 처리
                    errorMessage = userViewModel.errorMessage
                    showError = true
                    isLoading = false
                }
            }
        }
    }
}

// 역할 카드 컴포넌트
struct RoleCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // 아이콘
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(isSelected ? CLColor.SwiftUI.primaryColor : CLColor.SwiftUI.textSecondary)
                .frame(width: 40, height: 40)
            
            // 텍스트 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // 선택 표시
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(CLColor.SwiftUI.primaryColor)
            }
        }
        .padding(16)
        .background(isSelected ? CLColor.SwiftUI.primaryColor.opacity(0.1) : CLColor.SwiftUI.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? CLColor.SwiftUI.primaryColor : Color.clear, lineWidth: 2)
        )
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserState())
    }
}
