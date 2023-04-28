//
//  BlurModifier.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 28/04/23.
//

import Foundation
import SwiftUI

struct BlurModifier: ViewModifier {
    
    @State var blurred: Bool
    let showHideButton: Bool
    let text: String
    
    @Namespace private var namespace
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if blurred {
                    ZStack {
                        Rectangle()
                            .background(.ultraThinMaterial)
                        VStack {
                            Button {
                                withAnimation {
                                    blurred = false
                                }
                            } label: {
                                Image(systemName: "eye.circle.fill")
                                    .resizable()
                                    .matchedGeometryEffect(id: "eyeimage", in: namespace)
                                    .frame(width: 50, height: 50)
                                    .scaledToFit()
                            }
                            Text(text)
                                .multilineTextAlignment(.center)
                                .font(.caption2.weight(.bold))
                        }
                        .foregroundColor(.gray)
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                if showHideButton && !blurred {
                    Button {
                        withAnimation {
                            blurred = true
                        }
                    } label: {
                        Image(systemName: "eye.slash.circle.fill")
                            .resizable()
                            .background(.ultraThinMaterial, in: Circle())
                            .matchedGeometryEffect(id: "eyeimage", in: namespace)
                            .frame(width: 30, height: 30)
                            .scaledToFit()
                            
                    }
                    .foregroundColor(.gray)
                    .padding()
                }
            }
    }
    
}

extension View {
    
    func blur(_ blurred: Bool, showHideButton: Bool, text: String) -> some View {
        self
            .modifier(BlurModifier(blurred: blurred, showHideButton: showHideButton, text: text))
    }
}
