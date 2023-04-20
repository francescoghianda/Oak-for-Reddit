//
//  SubredditListingOrder.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 19/04/23.
//

import Foundation
import SwiftUI



@objc public enum SubredditListingOrder: Int, Hashable, CaseIterable, Identifiable, Equatable{
    case normal, popular, new
        
    public var id: Int {
        return self.rawValue
    }
    
    public var string: String {
        switch self {
        case .normal:
            return "default"
        case .popular:
            return "popular"
        case .new:
            return "new"
        }
    }
}

extension SubredditListingOrder: ViewRappresentable {
    
    
    var text: String {
        self.string.firstUppercased()
    }
    
    var icon: Image {
        switch self {
        case .normal:
            return Image(systemName: "suit.club.fill")
        case .popular:
            return Image(systemName: "flame")
        case .new:
            return Image(systemName: "bolt.fill")
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
