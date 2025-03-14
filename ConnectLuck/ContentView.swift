//
//  ContentView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct ContentView: View {
    @State var userState: UserState
    
    var body: some View {
        if userState.isLoggedIn {
            MainTabView(userState: userState)
        } else {
            LoginView(userState: userState)
        }
    }
}

#Preview {
    ContentView(userState: UserState())
}
