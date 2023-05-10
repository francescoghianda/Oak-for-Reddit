//
//  StringExtensions.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 09/05/23.
//

import Foundation

public extension String {
    
    func firstUppercased() -> String {
        if self.isEmpty {
            return ""
        }
        return "\(first?.uppercased() ?? "")\(self[index(after: startIndex)..<endIndex])"
    }
    
}

public extension String {
    
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
