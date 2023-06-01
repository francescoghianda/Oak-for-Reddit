//
//  Votable.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 10/05/23.
//

import Foundation
import SwiftUI

protocol Votable: AnyObject {
    var ups: Int { get set }
    var downs: Int { get set }
    var likes: Bool? { get set }
}

extension Votable {
    
    var upvoted: Bool {
        guard let likes = likes
        else {
            return false
        }
        return likes
    }
    
    var downvoted: Bool {
        guard let likes = likes
        else {
            return false
        }
        return !likes
    }
    
}
