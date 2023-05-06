//
//  CommentCard.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import SwiftUI

enum NewCommentStatus {
    case submitted(comment: Comment), canceled
}

struct CommentCard: View {
    
    @State private var replySheetPresented: Bool = false
    @State private var newCommentStatus: NewCommentStatus = .canceled
    private let showContextMenu: Bool
    
    @ObservedObject var comment: Comment
    @EnvironmentObject var post: Post
    
    init(comment: Comment, showContextMenu: Bool = true) {
        self.comment = comment
        self.showContextMenu = showContextMenu
    }
    
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
        .sheet(isPresented: $replySheetPresented, onDismiss: {
            
            if case .submitted(let comment) = newCommentStatus {
                self.comment.replies += comment
            }
            
        }, content: {
            NewCommentForm(parentId: comment.name, parentComment: comment, status: $newCommentStatus)
        })
        .contentShape(Rectangle())
        .contextMenu {
            if showContextMenu {
                LoggedActionButton {
                    replySheetPresented = true
                } label: {
                    Label("Reply", systemImage: "arrowshape.turn.up.left.fill")
                }
                .disabled(!comment.sendReplies)
            }
        }
        
    }
    
}
