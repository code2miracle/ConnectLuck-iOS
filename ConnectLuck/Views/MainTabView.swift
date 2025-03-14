//
//  MainTabView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var userState: UserState
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                FoodTruckListView()
                    .tag(1)
                
                EventListView()
                    .tag(2)
                
                ProfileView()
                    .tag(3)
            }
            
            // 커스텀 탭바
            CustomTabBar(selectedTab: $selectedTab, tabs: [
                TabItem(title: "홈", icon: "house.fill"),
                TabItem(title: "푸드트럭", icon: "car.fill"),
                TabItem(title: "행사", icon: "calendar"),
                TabItem(title: "마이", icon: "person.fill")
            ])
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    // 디자인 가이드에서 정의한 Spacing 상수
    private let componentPadding: CGFloat = 16
    private let tabIconSize: CGFloat = 24
    private let tabLabelSize: CGFloat = 10
    private let tabVerticalPadding: CGFloat = 12
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: tabIconSize))
                            .imageScale(.medium)
                        
                        Text(tabs[index].title)
                            .font(.system(size: tabLabelSize, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == index ? CLColor.SwiftUI.primaryColor : CLColor.SwiftUI.textSecondary)
                    .padding(.vertical, tabVerticalPadding)
                    .contentShape(Rectangle()) // 탭 영역 확장
                }
            }
        }
        .background(CLColor.SwiftUI.backgroundBase)
        .overlay(
            Divider().background(CLColor.SwiftUI.divider),
            alignment: .top
        )
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: -2)
    }
}

struct TabItem {
    let title: String
    let icon: String
}

// 임시 뷰들 (실제 구현 전 플레이스홀더)
struct MapPlaceholderView: View {
    var body: some View {
        Text("지도 뷰")
            .font(.title)
            .foregroundColor(CLColor.SwiftUI.textPrimary)
    }
}

struct EventListPlaceholderView: View {
    var body: some View {
        Text("행사 목록")
            .font(.title)
            .foregroundColor(CLColor.SwiftUI.textPrimary)
    }
}

struct ProfilePlaceholderView: View {
    var body: some View {
        Text("프로필")
            .font(.title)
            .foregroundColor(CLColor.SwiftUI.textPrimary)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(UserState())
    }
}

class UserState: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn = false
    
    init() {
        // 저장된 토큰으로 로그인 상태 체크
        isLoggedIn = TokenManager.shared.isLoggedIn
        
        // 로그인 상태면 사용자 정보 로드
        if isLoggedIn {
            loadUserInfo()
        }
    }
    
    // 사용자 정보 로드
    private func loadUserInfo() {
        Task {
            do {
                let user = try await AuthService.shared.getUserInfo()
                DispatchQueue.main.async {
                    self.currentUser = user
                }
            } catch {
                print("사용자 정보 로드 실패: \(error)")
                // 토큰이 유효하지 않은 경우 로그아웃 처리
                DispatchQueue.main.async {
                    self.logout()
                }
            }
        }
    }
    
    // 로그아웃
    func logout() {
        TokenManager.shared.clearToken()
        currentUser = nil
        isLoggedIn = false
    }
    
    // 권한 체크 메서드
    var isAdmin: Bool { currentUser?.isAdmin() ?? false }
    var isEventManager: Bool { currentUser?.isEventManager() ?? false }
    var isFoodTruckManager: Bool { currentUser?.isFoodTruckManager() ?? false }
}

extension UserState {
    // 사용자 정보 새로 가져오기
    func fetchUserInfo() async {
        do {
            let user = try await AuthService.shared.getUserInfo()
            DispatchQueue.main.async {
                self.currentUser = user
            }
        } catch {
            print("사용자 정보 업데이트 실패: \(error)")
            // 토큰이 유효하지 않은 경우 로그아웃 처리
            if let urlError = error as? URLError, urlError.code == .userAuthenticationRequired {
                DispatchQueue.main.async {
                    self.logout()
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
