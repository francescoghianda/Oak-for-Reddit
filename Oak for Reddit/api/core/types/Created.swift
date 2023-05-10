//
//  Created.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 10/05/23.
//

import Foundation

protocol Created {
    var created: Date { get }
    var createdUtc: Date { get }
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
