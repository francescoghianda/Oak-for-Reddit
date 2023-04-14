//
//  ClassicCommentView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import SwiftUI


struct ClassicCommentView: View {
    
    @ObservedObject var comment: Comment
    let level: Int
    @Binding var showReplies: Bool
    @Binding var mode: CommentsViewMode
    @Binding var order: CommentsOrder
    @Binding var loadingReplies: Bool
    
    @Namespace private var namespace
    
    var body: some View {
        
        VStack(alignment: .leading){
            Divider()
            CommentCard(comment: comment)
            Divider()
            
        }
        
        if comment.replies.count > 0 {
            
            
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
            
            if showReplies {
                Divider()
                
                VStack(alignment: .leading){
                    CommentsView(comment.replies, level: level + 1, mode: $mode, order: $order)
                        .padding(.leading, 3)
                    
                    if comment.replies.more != nil && comment.replies.more!.count > 0 {
                        Divider()
                        Button {
                            Task{
                                loadingReplies = true
                                comment.replies = await CommentsModel
                                    .loadMoreReplies(listing: comment.replies,
                                                     count: 10,
                                                     sort: order,
                                                     linkId: comment.linkId,
                                                     parentId: comment.name!)
                                //await comment.loadMoreReplies(sort: order)
                                loadingReplies = false
                            }
                        } label: {
                            HStack{
                                Text("Load more")
                                Spacer()
                                if loadingReplies {
                                    ProgressView()
                                }
                            }
                        }
                        .padding(.leading, 3)
                        .disabled(loadingReplies)
                        Divider()
                            .padding(.leading, 3)
                    }
                }
                .padding(.leading, 6)
                .overlay {
                    HStack{
                        Rectangle()
                            .foregroundColor(CommentView.getLevelColor(level))
                            .frame(width: 2)
                        Spacer()
                    }
                }
                
            }
            
        }
        
    }
    
}
