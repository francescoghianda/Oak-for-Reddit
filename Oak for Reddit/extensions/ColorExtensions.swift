//
//  ColorExtensions.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 09/05/23.
//

import SwiftUI

public extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        
        var hexFormatted: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
}

public extension Color {
    
    init(hexString: String, alpha: CGFloat = 1.0) {
        self.init(UIColor(hexString: hexString, alpha: alpha))
    }
    
}
