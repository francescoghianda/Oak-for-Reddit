//
//  RefreshableView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 28/03/23.
//

import Foundation
import SwiftUI

struct RefreshableView<Content: View>: View {
    
    var content: () -> Content
    
    @Environment(\.refresh) private var refresh
    @State private var isRefreshing = false
    

    var body: some View {
        VStack {
            
            if isRefreshing {
                ProgressView()
                    .transition(.scale)
            }
            
            content()
        }
        .animation(.default, value: isRefreshing)
        .background(GeometryReader {
            Color.clear.preference(key: ViewOffsetKey.self, value: -$0.frame(in: .global).origin.y)
        })
        .onPreferenceChange(ViewOffsetKey.self) {
                        
            if $0 < -200 && !isRefreshing {
                isRefreshing = true
                Task {
                    await refresh?()
                    await MainActor.run {
                        isRefreshing = false
                    }
                }
            }
        }
    }
    
}

public struct ViewOffsetKey: PreferenceKey {
    public typealias Value = CGFloat
    
    public static var defaultValue = CGFloat.zero
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
