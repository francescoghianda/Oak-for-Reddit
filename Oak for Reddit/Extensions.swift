//
//  Extensions.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 07/04/23.
//

import Foundation
import UIKit
import SwiftUI

extension Array {
    
    func split(at index: Int) -> (left: [Element], right: [Element]) {
        
        if self.count <= index {
            return (left: self, right: [])
        }
        
        let left = self[0..<index]
        let right = self[index..<self.count]
        
        return (left: Array(left), right: Array(right))
        
    }
    
}

extension Created {
    
    var timeSiceCreation: TimeInterval {
        Date.now.timeIntervalSince(created)
    }
    
    public func getTimeSiceCreationFormatted(maxDays: Int = 3, dateFormatter: DateFormatter? = nil) -> String {
        
        let seconds = self.timeSiceCreation
        let mins = Int(seconds / 60)
        let hours = Int(mins / 60)
        let days = Int(hours / 24)
        
        if (seconds < 60){
            return "now"//"\(seconds)s"
        }
        
        if (mins < 60) {
            return "\(mins)m"
        }
        
        if (hours < 24) {
            return "\(hours)h"
        }

        if (days <= maxDays) {
            return "\(days)g"
        }
        
        var formatter = dateFormatter
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.dateFormat = "dd/MM/yy"
        }
        
        return formatter!.string(from: self.created)
    }
    
}

extension UIColor {
    
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

extension Color {
    
    init(hexString: String, alpha: CGFloat = 1.0) {
        self.init(UIColor(hexString: hexString, alpha: alpha))
    }
    
}


extension String {
    
    func firstUppercased() -> String {
        return "\(first?.uppercased() ?? "")\(self[index(after: startIndex)..<endIndex])"
    }
    
}

extension Collection {

    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

