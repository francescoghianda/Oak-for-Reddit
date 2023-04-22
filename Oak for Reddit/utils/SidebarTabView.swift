//
//  SidebarTabView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 22/04/23.
//

import Foundation
import SwiftUI


fileprivate struct Sidebar: View {
    
    @Binding var selected: Int
    
    var body: some View {
        
        ZStack{
            
            List {
                
                Button{
                    selected = 1
                } label: {
                    Text("Link 1")
                }
                
                Button{
                    selected = 2
                } label: {
                    Text("Link 2")
                }
                
            }
            .listStyle(.sidebar)
            
            VStack{
                Rectangle()
                    .frame(height: 50)
                    .background(.ultraThinMaterial)
                Spacer()
            }
            .ignoresSafeArea()
        }
        .frame(maxWidth: 350, maxHeight: .infinity, alignment: .topLeading)
        
    }
    
}

struct SidebarTabView: View {
    
    @State var selected: Int = 1
    
    var body: some View {
        
        HStack {
            
            Sidebar(selected: $selected)
            
            if selected == 1 {
                Text("Content 1")
            }
            else if selected == 2 {
                Text("Content 2")
            }
            
            Spacer()
        }
        
        
    }
    
}
