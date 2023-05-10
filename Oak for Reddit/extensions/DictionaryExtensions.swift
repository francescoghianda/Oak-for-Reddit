//
//  DictionaryExtensions.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 09/05/23.
//

import Foundation

extension Dictionary {
    
    public func percentEncoded() -> Data? {
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
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
    
}

extension Dictionary where Key == String, Value: Any {
    
    public func get<T>(_ key: Key) -> T? {
        return self[key] as? T
    }
    
    public func get<T>(_ key: Key, defaultValue: T? = nil) -> T {
        return self.get(key) ?? defaultValue!
    }
    
    public func getBool(_ key: Key) -> Bool? {
        guard let value = self[key] as? Int else {
            return nil
        }
        return value != 0
    }
    
    public func getBool(_ key: Key) -> Bool {
        self.getBool(key) ?? false
    }
    
    public func getDate(_ key: Key) -> Date? {
        guard let time = self[key] as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: time)
    }
    
    public func getDate(_ key: Key) -> Date {
        self.getDate(key)!
    }
    
    public func getDictionary(_ key: Key) -> [String : Any]? {
        guard let dict = self[key] as? [String : Any] else {
            return nil
        }
        return dict
    }
    
    public func getDictionaryArray(_ key: Key) -> [[String : Any]]? {
        guard let array = self[key] as? [[String : Any]] else {
            return nil
        }
        return array
    }
    
    public func getUrl(_ key: Key) -> URL? {
        
        guard let path = self[key] as? String else {
            return nil
        }
        
        return URL(string: path)
    }
    
    public func getHtmlEcodedString(_ key: String, encoding: String.Encoding = .utf16) -> String? {
        
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
