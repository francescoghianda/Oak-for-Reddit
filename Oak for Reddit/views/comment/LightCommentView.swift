//
//  LightCommentView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import SwiftUI

struct LightCommentView: View {
    
    @EnvironmentObject var model: CommentsModel
    
    @ObservedObject var comment: Comment
    let level: Int
    @Binding var showReplies: Bool
    @Binding var mode: CommentsViewMode
    @Binding var order: CommentsOrder
    @Binding var loadingReplies: Bool
    @State var error: Error? = nil
    
    var body: some View {
        
        HStack(spacing: 0){
            
            if level > 0 {
                CommentView.getLevelColor(level-1)
                    .frame(width: 2)
                    .padding(.trailing, 6)
            }
            
            VStack(alignment: .leading){
                Divider()
                CommentCard(comment: comment)
                Divider()
                
                if comment.replies.count > 0 {
                    showRepliesButton()
                    Divider()
                }
                
            }
            
        }
        
        if showReplies {
            
            CommentsView(comment.replies, level: level + 1, mode: $mode, order: $order)
                .padding(.leading, 8)
            
            if comment.replies.more != nil && comment.replies.more!.count > 0 {
                
                loadMoreButton()
                    .padding(.leading, 8)
            }
            
        }

        
    }
    
    private func showRepliesButton() -> some View {
        
        Button{
            withAnimation {
                showReplies.toggle()
            }
        } label:{
            
            HStack{
                Text(showReplies ? "Hide replies" : "Show replies")
                Spacer()
                Image(systemName: "chevron.right")
                    .rotationEffect(showReplies ? .degrees(90.0) : .degrees(0.0))
            }
        }
    }
    
    private func loadMoreButton() -> some View {
        
        HStack {
            CommentView.getLevelColor(level)
                .frame(width: 2)
                //.padding(.trailing, 6)
            
            VStack {
                
                Divider()
                
                Button {
                    loadMore()
                } label: {
                    HStack{
                        Text("Load more")
                        Spacer()
                        if loadingReplies {
                            ProgressView()
                        }
                    }
                }
                .disabled(loadingReplies)
                
                Divider()
                
            }
        }
    }
    
    private func loadMore() {
        
        loadingReplies = true
        error = nil
        Task {
            
            do {
                let replies = try await model
                    .loadMoreReplies(listing: comment.replies,
                                     count: 10,
                                     sort: order,
                                     linkId: comment.linkId,
                                     parentId: comment.name)
                
                Task { @MainActor in
                    comment.replies = replies
                    loadingReplies = false
                }
            }
            catch {
                Task { @MainActor in
                    self.error = error
                    loadingReplies = false
                }
            }
            
            
        }
    }
    
}
