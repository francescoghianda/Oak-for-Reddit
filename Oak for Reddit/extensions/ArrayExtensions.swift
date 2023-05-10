//
//  ArrayExtensions.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 09/05/23.
//

import Foundation

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
