//
//  PostView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 24/03/23.
//

import SwiftUI

fileprivate struct CommentCard: View {
    
    let comment: Comment
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10){
            HStack{
                Text("u/\(comment.author)")
                Text("·")
                Text(comment.getTimeSiceCreationFormatted())
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            Text(comment.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        
    }
    
}

fileprivate struct ClassicCommentView: View {
    
    let comment: Comment
    let level: Int
    @Binding var showReplies: Bool
    @Binding var mode: CommentsViewMode
    @Binding var order: CommentsOrder
    
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
                    
                    if comment.replies.more != nil {
                        Divider()
                        Button("Load more") {
                            
                        }
                        .padding(.leading, 3)
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

fileprivate struct LightCommentView: View {
    
    let comment: Comment
    let level: Int
    @Binding var showReplies: Bool
    @Binding var mode: CommentsViewMode
    @Binding var order: CommentsOrder
    
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
            }
            
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
                
                CommentsView(comment.replies, level: level + 1, mode: $mode, order: $order)
                    .padding(.leading, 8)
                
                if comment.replies.more != nil {
                    Button("Load more") {
                        
                    }
                    .padding(.leading, 8)
                    
                    Divider()
                        .padding(.leading, 8)
                }
                
            }

        }

        
    }
    
}

fileprivate struct CommentView: View {
    
    static let levelColors: [Color] = [.red, .orange, .yellow, .green, .teal, .blue, .purple, .indigo]
    
    static func getLevelColor(_ level: Int) -> Color {
        CommentView.levelColors[level % CommentView.levelColors.count]
    }
    
    let comment: Comment
    let level: Int
    
    let ligthMode: Bool = true
    
    @State var showReplies: Bool = false
    @Binding var mode: CommentsViewMode
    @Binding var order: CommentsOrder
    
    var body: some View {
        
        switch mode {
        case .classic:
            ClassicCommentView(comment: comment,
                               level: level,
                               showReplies: $showReplies,
                               mode: $mode,
                               order: $order)
        case .light:
            LightCommentView(comment: comment,
                             level: level,
                             showReplies: $showReplies,
                             mode: $mode,
                             order:$order)
        }
        
    }
}


fileprivate struct CommentsView: View {
    
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
        
        ForEach(comments) { comment in
            
            CommentView(comment: comment, level: level, mode: $mode, order: $order)
            
        }
        
    }
}

fileprivate enum CommentsViewMode{
    case classic, light
}

struct PostView: View {
    
    
    let post: Post
    @Binding var linkIsPresented: Bool
    //var namespace: Namespace.ID? = nil
    //@Binding var postToShow: Post?
    @StateObject var model: CommentsModel
    @State var commentsOrder: CommentsOrder = .confidence
    @State var showCommentsOrderPicker: Bool = false
    
    @State private var commentsViewMode: CommentsViewMode = .classic
    
    
    init(post: Post, linkIsPresented: Binding<Bool>) {
        self.post = post
        self._linkIsPresented = linkIsPresented
        self._model = StateObject(wrappedValue: CommentsModel(postId: post.thingId!))
    }
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                
                /*Button {
                    withAnimation(.spring()) {
                        postToShow = nil
                    }
                } label: {
                    Text("close")
                }
                .padding()*/
                
                HStack{
                    Text("Posted by u/\(post.author) ⋅ \(post.getTimeSiceCreationFormatted())")
                        
                    Spacer()
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom)
                
                Text(post.title)
                    //.matchedGeometryEffect(id: "posttitle\(post.uuid)", in: namespace!, properties: .position)
                    .font(.headline)
                
                if post.containsMedia {
                    PostMediaViewer(post: post, cornerRadius: 10, showContextMenu: true)
                        //.scaledToFit()
                        //.matchedGeometryEffect(id: "postmedia\(post.uuid)", in: namespace!, properties: .position, anchor: .center)
                        .padding([.top, .bottom])
                        
                }
                else if post.postLinkType == .link {
                    LinkAndThumbnailView(thumbnailUrl: post.thumbnailUrl, postUrl: post.url)
                        .onTapGesture {
                            linkIsPresented.toggle()
                        }
                }
                
                    
                if !post.selfText.isEmpty {
                    SelfText(post.selfText)
                        .padding(.bottom)
                }
                
                HStack{
                    Button {
                        
                    } label: {
                        Image("arrowshape.up.fill")
                    }
                    
                    Text(post.ups.toKNotation())
                        .frame(width: 35, alignment: .leading)
                        .font(.system(size: 12))
                    
                    Button {
                        
                    } label: {
                        Image("arrowshape.up.fill")
                            .rotationEffect(.degrees(180))
                            
                            //.padding(.leading, 5)
                    }
                    
                    HStack{
                        Image(systemName: "message.fill")
                        Text("\(post.numComments)")
                            .font(.system(size: 12))
                    }
                    .padding(.leading)
                }
                .foregroundColor(Color.gray)
                
                HStack{
                    Text("Comments")
                        .font(.title)
                        .padding([.top, .bottom])
                    Spacer()
                    
                    Button {
                        withAnimation {
                            showCommentsOrderPicker.toggle()
                        }
                    } label: {
                        HStack{
                            Label("Sort: \(commentsOrder.viewString)", systemImage: "arrow.up.arrow.down")
                            //Spacer()
                            Image(systemName: "chevron.right")
                                .rotationEffect(showCommentsOrderPicker ? .degrees(90.0) : .degrees(0.0))
                        }
                    }

                }
                
                if showCommentsOrderPicker {
                    
                    ForEach(CommentsOrder.allCases, id: \.id) { item in
                        
                        Button{
                            withAnimation {
                                commentsOrder = item
                                showCommentsOrderPicker = false
                            }
                        } label: {
                            HStack{
                                if item == commentsOrder {
                                    Image(systemName: "checkmark")
                                        .padding(.trailing, 20)
                                }
                                
                                Text(item.viewString)
                                
                            }
                            .foregroundColor(.gray)
                        }
                        
                    }
                    
                }
                
                CommentsView(model.comments, mode: $commentsViewMode, order: $commentsOrder)
                
                Spacer()
            }
            .padding([.leading, .trailing])
            
        }
        .navigationBarTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing){
                
                Button {
                    
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                
                Menu {
                    
                    Picker("View mode", selection: $commentsViewMode) {
                        Text("Classic").tag(CommentsViewMode.classic)
                        Text("Light").tag(CommentsViewMode.light)
                    }
                    
                    
                } label: {
                    Image(systemName: "ellipsis")
                }


            }
            
            
        }
        .task{
            await model.load()
        }
        
        
        
    }
}

struct PostView_Previews: PreviewProvider {
    
    static let postData: [String : Any] = [
        "ups": 100000,
        "downs": 2,
        "likes": 0,
        "created": 0.0,
        "created_utc": 0.0,
        "author": "author",
        "hidden": 0,
        "is_self": 0,
        "locked": 1,
        "num_comments": 20,
        "over_18": 1,
        "score": 8,
        "selftext": "Testo di prova",
        "subreddit": "subreddit",
        "subreddit_id": "1234",
        "thumbnail": "image",
        "title": "Lorem Ipsum is simply dummy text",
        "permalink": "aaaa",
        "url": "https://www.zooplus.it/magazine/wp-content/uploads/2020/05/1-32.jpg",
        "stickied": 1
        //"media": media
    ]
    
    static var previews: some View {
        PostView(post: Post(id: nil, name: nil, kind: "", data: postData), linkIsPresented: Binding.constant(false))
    }
}
