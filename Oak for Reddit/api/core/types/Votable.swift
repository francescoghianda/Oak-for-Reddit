//
//  Votable.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 10/05/23.
//

import Foundation

protocol Votable {
    var ups: Int { get }
    var downs: Int { get }
    var likes: Bool? { get }
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
