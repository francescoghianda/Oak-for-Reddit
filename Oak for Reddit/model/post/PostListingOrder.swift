//
//  PostListingOrder.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 19/04/23.
//

import Foundation
import SwiftUI


enum TimeRange: String, CaseIterable, Identifiable{
    case hour = "Hour", day = "Day", week = "Week", month = "Month", year = "Year", all = "All"
    
    var id: String {
        return self.rawValue
    }
}

extension TimeRange {
    
    var systemImage: String {
        switch self {
        case .hour:
            return "clock"
        case .day:
            return "sun.max.fill"
        case .week:
            return "w.circle"
        case .month:
            return "calendar"
        case .year:
            return "sparkles.rectangle.stack"
        case .all:
            return "globe"
        }
    }
    
    var color: Color {
        switch self {
        case .hour:
            return .blue
        case .day:
            return .yellow
        case .week:
            return .green
        case .month:
            return .red
        case .year:
            return .teal
        case .all:
            return .purple
        }
    }
    
}

enum PostListingOrder: Hashable, CaseIterable, Identifiable, Equatable {
    case best, hot, new, rising
    case top(range: TimeRange), controversial(range: TimeRange)
    
    static let rawValueSeparator: Character = "@"
    
    var id: String {
        self.rawValue
    }
    
    var rawValue: String {
        switch self {
        case .best:
            return "best"
        case .hot:
            return "hot"
        case .new:
            return "new"
        case .rising:
            return "rising"
        case .top(let range):
            return "top@\(range.rawValue)"
        case .controversial(let range):
            return "controversial@\(range.rawValue)"
        }
    }
    
    var rawValueNoRange: String {
        String(rawValue.split(separator: PostListingOrder.rawValueSeparator).first!)
    }
    
    static var allCases: [PostListingOrder] {
        return [.best, .hot, .new, .rising, .top(range: .all), .controversial(range: .all)]
    }
}

extension PostListingOrder {
    
    var text: String {
        return rawValueNoRange.firstUppercased()
    }
    
    var systemImage: String {
        switch self {
        case .best:
            return "line.horizontal.star.fill.line.horizontal"
        case .hot:
            return "flame"
        case .new:
            return "clock"
        case .rising:
            return "chart.line.uptrend.xyaxis"
        case .top:
            return "sparkle.magnifyingglass"
        case .controversial:
            return "bolt.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .best:
            return .purple
        case .hot:
            return .red
        case .new:
            return .blue
        case .rising:
            return .green
        case .top:
            return .orange
        case .controversial:
            return .yellow
        }
    }
    
    private static var dict: [String : PostListingOrder] = [
        "best": .best,
        "hot": .hot,
        "new": .new,
        "rising": .rising,
        "top": .top(range: .all),
        "controversial": .controversial(range: .all)
    ]
    
    init?(rawValue: String) {
        
        let splitted = rawValue.split(separator: PostListingOrder.rawValueSeparator)
        
        guard
            let rawValueNoRange = splitted.first,
            let value = PostListingOrder.dict[String(rawValueNoRange)]
        else {
            return nil
        }
        
        if let rangeRawValue = splitted[safe: 1] {
            
            guard let range = TimeRange(rawValue: String(rangeRawValue))
            else {
                return nil
            }
            
            switch value {
            case .top:
                self = .top(range: range)
            case .controversial:
                self = .controversial(range: range)
            default:
                return nil
            }
            
        }
        else {
            self = value
        }
        
    }
    
    
}
