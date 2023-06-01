//
//  Toast.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 29/04/23.
//

import SwiftUI

enum ToastDuration {
    case permanent
    case time(_ seconds: Double)
}

struct Toast<Presenting: View, Content: View>: View {
    
    @ViewBuilder let presenting: () -> Presenting
    @Binding var isPresenting: Bool
    let duration: ToastDuration
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
                if case .time(let seconds) = duration, isPresenting {
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.isPresenting = false
                    }
                }
            }
        }
        
        
    }
}

extension View {
    
    func toast<Content: View>(isPresenting: Binding<Bool>, duration: ToastDuration = .time(2), content: @escaping () -> Content) -> some View {
        
        Toast(presenting: { self }, isPresenting: isPresenting, duration: duration, content: content)
        
    }
    
}
