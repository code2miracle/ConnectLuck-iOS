//
//  StatusBadge.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/15/25.
//

import SwiftUI

struct StatusBadge: View {
    var status: EventStatus
    var text: String? = nil
    
    var body: some View {
        Text(text ?? status.displayText)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status.color)
            .cornerRadius(12)
    }
}


#Preview {
    StatusBadge(status: .recruiting, text: "현재 영업 중")
}
