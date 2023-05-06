//
//  SearchBar.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 05/05/23.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
    
    var body: some View {
        
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $text)
        }
        .padding(7)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        
    }
}

struct SearchBar_Previews: PreviewProvider {
    
    @State static var text: String = ""
    
    static var previews: some View {
        SearchBar(text: $text)
            .previewDevice("iPhone 12")
            .previewLayout(/*@START_MENU_TOKEN@*/.device/*@END_MENU_TOKEN@*/)
            
    }
}
