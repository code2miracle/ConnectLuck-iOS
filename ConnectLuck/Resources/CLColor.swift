//
//  CLColor.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

enum CLColor { }

extension CLColor {
    enum SwiftUI {
        // 브랜드 컬러
        static var primaryColor: Color = Color("PrimaryColor", bundle: nil)
        static var accentColor: Color = Color("AccentColor", bundle: nil)
        
        // 중립 컬러
        static var backgroundBase: Color = Color("BackgroundBase", bundle: nil)
        static var surface: Color = Color("Surface", bundle: nil)
        static var divider: Color = Color("Divider", bundle: nil)
        static var textPrimary: Color = Color("TextPrimary", bundle: nil)
        static var textSecondary: Color = Color("TextSecondary", bundle: nil)
        
        // 상태 컬러
        static var success: Color = Color("Success", bundle: nil)
        static var warning: Color = Color("Warning", bundle: nil)
        static var error: Color = Color("Error", bundle: nil)
        static var info: Color = Color("Info", bundle: nil)
        
    }
}
