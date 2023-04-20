//
//  SubredditListingOrder.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 19/04/23.
//

import Foundation
import SwiftUI

enum SubredditListingOrder: String, Hashable, CaseIterable, Identifiable, Equatable{
    case normal = "default", popular, new
        
    var id: String {
        return self.rawValue
    }
}

extension SubredditListingOrder {
    
    var displayText: String {
        rawValue.firstUppercased()
        //"\(rawValue.first?.uppercased() ?? "")\(rawValue[rawValue.index(after: rawValue.startIndex)..<rawValue.endIndex])"
    }
    
    var systemImage: String {
        switch self {
        case .normal:
            return "suit.club.fill"
        case .popular:
            return "flame"
        case .new:
            return "bolt.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .normal:
            return .green
        case .popular:
            return .red
        case .new:
            return .yellow
        }
    }
    
}
