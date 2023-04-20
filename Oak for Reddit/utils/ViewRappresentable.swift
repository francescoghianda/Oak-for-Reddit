//
//  ViewRappresentable.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 20/04/23.
//

import SwiftUI

protocol ViewRappresentable {
    associatedtype Icon: View
    
    var text: String { get }
    var icon: Icon { get }
    var color: Color { get }
}
