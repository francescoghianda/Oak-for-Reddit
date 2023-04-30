//
//  Toast.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 29/04/23.
//

import SwiftUI

struct Toast<Presenting: View, Content: View>: View {
    
    @ViewBuilder let presenting: () -> Presenting
    @Binding var isPresenting: Bool
    let autoClose: Bool
    @ViewBuilder let content: () -> Content
    
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            presenting()
            
            VStack {
                content()
                    .padding()
            }
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .transition(.opacity)
            .opacity(isPresenting ? 1 : 0)
            .animation(.easeInOut, value: isPresenting)
            .onChange(of: isPresenting) { isPresenting in
                if isPresenting && autoClose {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isPresenting = false
                    }
                }
            }
        }
        
        
    }
}

extension View {
    
    func toast<Content: View>(isPresenting: Binding<Bool>, autoClose: Bool = true, content: @escaping () -> Content) -> some View {
        
        Toast(presenting: { self }, isPresenting: isPresenting, autoClose: autoClose, content: content)
        
    }
    
}
