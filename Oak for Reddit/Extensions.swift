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
    
    init?(htmlEncodedString: String) {

        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        self.init(attributedString.string)

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

extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension Dictionary where Key == String, Value: Any {
    
    func get<T>(_ key: Key) -> T? {
        return self[key] as? T
    }
    
    func get<T>(_ key: Key, defaultValue: T? = nil) -> T {
        return self.get(key) ?? defaultValue!
    }
    
    func getBool(_ key: Key) -> Bool? {
        guard let value = self[key] as? Int else {
            return nil
        }
        return value != 0
    }
    
    func getBool(_ key: Key) -> Bool {
        self.getBool(key) ?? false
    }
    
    func getDate(_ key: Key) -> Date? {
        guard let time = self[key] as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: time)
    }
    
    func getDate(_ key: Key) -> Date {
        self.getDate(key)!
    }
    
    func getDictionary(_ key: Key) -> [String : Any]? {
        guard let dict = self[key] as? [String : Any] else {
            return nil
        }
        return dict
    }
    
    func getDictionaryArray(_ key: Key) -> [[String : Any]]? {
        guard let array = self[key] as? [[String : Any]] else {
            return nil
        }
        return array
    }
    
    func getUrl(_ key: Key) -> URL? {
        
        guard let path = self[key] as? String else {
            return nil
        }
        
        return URL(string: path)
    }
    
    func getHtmlEcodedString(_ key: String, encoding: String.Encoding = .utf16) -> String? {
        
        guard let encodedString = self[key] as? String,
              let data = encodedString.data(using: encoding),
              let attrStr = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        else {
            return nil
        }
        
        return attrStr.string
    }
    
    func getThingMedia(_ key: String) -> Media? {
        
        guard let data = self[key] as? [String : Any] else {
            return nil
        }
        
        return Media.build(from: data)
    }
    
}

