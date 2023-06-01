//
//  Created_Tests.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 10/05/23.
//

import XCTest
@testable import Oak_for_Reddit

class Created_Tests: XCTestCase {
    
    class CreatedTest: Created {
        var created: Date
        var createdUtc: Date
        
        init(date: Date) {
            self.created = date
            self.createdUtc = date
        }
    }
    
    func test_Created_timeSinceCreation() {
        
        let created = CreatedTest(date: .now.advanced(by: -5))
        XCTAssertEqual(5, Int(created.timeSiceCreation))
    }
    
    func test_Created_getTimeSiceCreationFormatted_shouldReturnNow() {
     
        let created = CreatedTest(date: .now)
        XCTAssertEqual("now", created.getTimeSiceCreationFormatted())
    }
    
    func test_Created_getTimeSiceCreationFormatted_shouldReturnNumberOfMinutes() {
     
        let created = CreatedTest(date: .now.advanced(by: -120))
        XCTAssertEqual("2m", created.getTimeSiceCreationFormatted())
    }
    
    func test_Created_getTimeSiceCreationFormatted_shouldReturnNumberOfHours() {
     
        let created = CreatedTest(date: .now.advanced(by: -(2 * 3600)))
        XCTAssertEqual("2h", created.getTimeSiceCreationFormatted())
    }
    
    func test_Created_getTimeSiceCreationFormatted_shouldReturnNumberOfDays() {
     
        let created = CreatedTest(date: .now.advanced(by: -(24 * 3600 * 2)))
        XCTAssertEqual("2g", created.getTimeSiceCreationFormatted(maxDays: 2))
    }
    
    func test_Created_getTimeSiceCreationFormatted_shouldReturnFormattedDate() {
     
        let date: Date = .now.advanced(by: -(24 * 3600 * 2))
        let created = CreatedTest(date: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        XCTAssertEqual(dateFormatter.string(from: date), created.getTimeSiceCreationFormatted(maxDays: 1, dateFormatter: dateFormatter))
    }

}
