//
//  PostTags.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 23/04/23.
//

import SwiftUI

fileprivate struct BorderedTextSymbol: View {
    let color: Color
    let text: String
    
    var body: some View {
        
        Text(text)
            .padding([.leading, .trailing], 5)
            .padding([.top, .bottom], 2)
            .foregroundColor(color)
            .font(.custom("Arial", size: 12))
            .background {
                Rectangle()
                    .stroke(color, lineWidth: 3)
                    .cornerRadius(2)
            }
    }
}

struct NsfwSymbol: View{
    
    let color = Color(red: 255/255, green: 88/255, blue: 91/255)
    
    var body: some View {
        BorderedTextSymbol(color: color, text: "nsfw")
    }
}

struct SpoilerSymbol: View {
    
    var body: some View {
        BorderedTextSymbol(color: .gray, text: "spoiler")
    }
    
}

struct OCSymbol: View {
    
    var body: some View {
        Text("OC")
            .foregroundColor(.white)
            .font(.custom("Arial", size: 12))
            .padding(2)
            .background{
                Rectangle()
                    .fill(.blue)
            }
    }
    
}

struct PostTags_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NsfwSymbol()
            SpoilerSymbol()
            OCSymbol()
        }
        .previewLayout(.sizeThatFits)
    }
}
