//
//  CommentCard.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import SwiftUI

struct CommentCard: View {
    
    let comment: Comment
    @EnvironmentObject var post: Post
    
    private func authorLabel() -> some View {
        HStack{
            if post.author == comment.author {
                Text("OP")
                    .foregroundColor(.blue)
                    .bold()
            }
            
            if comment.distinguished == "admin"{
                Text("A")
                    .foregroundColor(.red)
                    .bold()
            }
            else if comment.distinguished == "moderator" {
                Text("M")
                    .foregroundColor(.green)
                    .bold()
            }
        }
    }
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10){
            HStack{
                Text("u/\(comment.author)")
                authorLabel()
                Spacer()
                Text("\(comment.score?.description ?? "_") pt")
                Text("·")
                Text(comment.getTimeSiceCreationFormatted())
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            Text((try? AttributedString(markdown: comment.body)) ?? "Error loading comment")
                .fixedSize(horizontal: false, vertical: true)
        }
        
    }
    
}
