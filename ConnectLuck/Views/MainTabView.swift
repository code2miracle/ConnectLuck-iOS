//
//  MainTabView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(UserState.self) var userState : UserState
    
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




#Preview {
    MainTabView()
}
