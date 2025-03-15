//
//  ConnectLuckApp.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/13/25.
//

import SwiftUI

@main
struct ConnectLuckApp: App {
    @State private var userState = UserState()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environment(userState)
            .task {
                // 앱 시작 시 서버 연결 테스트
                let isConnected = await UserService.shared.testServerConnection()
                print("서버 연결 상태: \(isConnected ? "정상" : "비정상")")
                
                // 저장된 토큰이 있다면 사용자 정보 로드
                if TokenManager.shared.isLoggedIn {
                    userState.loadUserInfo()
                }
            }
        }
    }
}
