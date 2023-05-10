//
//  CommentListView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import SwiftUI

@objc public enum CommentsViewMode: Int {
    case classic, light
}

extension CommentsViewMode {
    var text: String {
        switch self {
        case .classic:
            return "Classic"
        case .light:
            return "Ligth"
        }
    }
}

struct CommentsView: View {
    
    let comments: Listing<Comment>
    let level: Int
    @Binding var mode: CommentsViewMode
    @Binding var order: CommentsOrder
    
    init(_ comments: Listing<Comment>, level: Int = 0,
         mode: Binding<CommentsViewMode>, order: Binding<CommentsOrder>) {
        
        self.comments = comments
        self.level = level
        self._mode = mode
        self._order = order
    }
    
    var body: some View {
        
        VStack{
            ForEach(comments) { comment in
                
                CommentView(comment: comment, level: level, mode: $mode, order: $order)
                
            }
        }
        .animation(.easeInOut, value: comments)
        
        
    }
}

struct PostCommentsView: View {
    
    @ObservedObject var model: CommentsModel
    //var model: ObservedObject<CommentsModel>
    @Binding var viewMode: CommentsViewMode
    @Binding var order: CommentsOrder
    @EnvironmentObject var post: Post
    @State var loadingMoreComments: Bool = false
    @State var error: Error? = nil
    
    var body: some View {
        
        CommentsView(model.comments, mode: $viewMode, order: $order)
            .environmentObject(model)
        
        if model.comments.more != nil && model.comments.more!.count > 0 {
            Button{
                loadingMoreComments = true
                Task {
                    do {
                        let newComments = try await model
                            .loadMoreReplies(listing: model.comments,
                                             count: 50,
                                             sort: order,
                                             linkId: post.name,
                                             parentId: post.name)
                        
                        Task { @MainActor in
                            self.model.comments = newComments
                        }
                    } catch {
                        self.error = error
                    }
                    loadingMoreComments = false
                }
            } label: {
                VStack{
                    Divider()
                    HStack{
                        Spacer()
                        if loadingMoreComments {
                            ProgressView()
                        }
                        else {
                            Text("Load more")
                        }
                        Spacer()
                        
                    }
                    Divider()
                }
            }
            
        }
        
    }
    
}
