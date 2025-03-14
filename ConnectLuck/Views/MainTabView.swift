//
//  MainTabView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct MainTabView: View {
    @State var userState: UserState
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(userState: userState)
                    .tag(0)
                
                FoodTruckListView(userState: userState)
                    .tag(1)
                
                EventListView()
                    .tag(2)
                
                ProfileView(userState: userState)
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

#Preview {
    MainTabView(userState: UserState())
}
