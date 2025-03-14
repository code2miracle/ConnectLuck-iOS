//
//  ConnectLuckApp.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/13/25.
//

import SwiftUI

@main
struct ConnectLuckApp: App {
    @StateObject private var userState = UserState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userState)
                .task {
                    // 앱 시작 시 서버 연결 테스트
                    let isConnected = await AuthService.shared.testServerConnection()
                    print("서버 연결 상태: \(isConnected ? "정상" : "비정상")")
                }
        }
    }
}
