//
//  MainTabView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var userState: UserState
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 홈 탭
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house")
                }
                .tag(0)
            
            // 지도 탭
            MapPlaceholderView()
                .tabItem {
                    Label("지도", systemImage: "map")
                }
                .tag(1)
                
            // 행사 탭
            EventListPlaceholderView()
                .tabItem {
                    Label("행사", systemImage: "calendar")
                }
                .tag(2)
            
            // 푸드트럭 탭
            FoodTruckListView()
                .tabItem {
                    Label("푸드트럭", systemImage: "box.truck")
                }
                .tag(3)
            
            // 마이페이지 탭
            ProfilePlaceholderView()
                .tabItem {
                    Label("마이페이지", systemImage: "person")
                }
                .tag(4)
        }
        .accentColor(Color(hex: "#0066CC")) // 주 액센트 컬러
        .onAppear {
            // 탭바 스타일 설정 - 흰색 배경, 검은색 아이콘
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            
            // 선택되지 않은 탭 아이템 색상 설정
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(hex: "#757575"))
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(Color(hex: "#757575"))
            ]
            
            // 선택된 탭 아이템 색상 설정
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "#0066CC"))
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color(hex: "#0066CC"))
            ]
            
            // 상단 경계선 설정
            appearance.shadowColor = UIColor(Color(hex: "#E0E0E0"))
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

// 임시 뷰들 (실제 구현 전 플레이스홀더)
struct MapPlaceholderView: View {
    var body: some View {
        Text("지도 뷰")
            .font(.title)
            .foregroundColor(Color(hex: "#212121"))
    }
}

struct EventListPlaceholderView: View {
    var body: some View {
        Text("행사 목록")
            .font(.title)
            .foregroundColor(Color(hex: "#212121"))
    }
}

struct ProfilePlaceholderView: View {
    var body: some View {
        Text("프로필")
            .font(.title)
            .foregroundColor(Color(hex: "#212121"))
    }
}

// 헥스 코드로 Color 만들기 위한 확장
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(UserState())
    }
}

// 사용자 상태 관리용 클래스
class UserState: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    // 권한 체크 메서드
    var isAdmin: Bool { currentUser?.isAdmin() ?? false }
    var isEventManager: Bool { currentUser?.isEventManager() ?? false }
    var isFoodTruckManager: Bool { currentUser?.isFoodTruckManager() ?? false }
}

#Preview {
    MainTabView()
}
