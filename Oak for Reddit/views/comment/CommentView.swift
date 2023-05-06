//
//  CommentView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import SwiftUI


struct CommentView: View {
    
    static let levelColors: [Color] = [.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .pink]
    
    static func getLevelColor(_ level: Int) -> Color {
        CommentView.levelColors[level % CommentView.levelColors.count]
    }
    
    @ObservedObject var comment: Comment
    let level: Int
    
    let ligthMode: Bool = true
    
    @State var showReplies: Bool = false
    @State var loadingReplies: Bool = false
    @Binding var mode: CommentsViewMode
    @Binding var order: CommentsOrder
    
    var body: some View {
        
        switch mode {
        case .classic:
            ClassicCommentView(comment: comment,
                               level: level,
                               showReplies: $showReplies,
                               mode: $mode,
                               order: $order,
                               loadingReplies: $loadingReplies)
        case .light:
            LightCommentView(comment: comment,
                             level: level,
                             showReplies: $showReplies,
                             mode: $mode,
                             order:$order,
                             loadingReplies: $loadingReplies)
        }
        
    }
}
