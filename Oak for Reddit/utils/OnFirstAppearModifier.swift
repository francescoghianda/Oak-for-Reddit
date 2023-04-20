//
//  OnFirstAppearModifier.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 20/04/23.
//

import Foundation
import SwiftUI


struct OnFirstAppearModifier: ViewModifier {
    
    @State var firstAppear: Bool = true
    private let action: () -> Void
    
    init(perform action: @escaping () -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            guard firstAppear else { return }
            firstAppear = false
            action()
        }
    }
    
}

extension View {
    
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearModifier(perform: action))
    }
    
}

