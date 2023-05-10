//
//  Extensions.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 07/04/23.
//

import Foundation
import UIKit
import SwiftUI










extension UINavigationController: UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}



