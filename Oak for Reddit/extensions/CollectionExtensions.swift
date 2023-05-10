//
//  CollectionExtensions.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 08/05/23.
//

import Foundation

extension Collection {

    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
