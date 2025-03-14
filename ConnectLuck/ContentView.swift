//
//  ContentView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var userState: UserState
    
    var body: some View {
        if userState.isLoggedIn {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
