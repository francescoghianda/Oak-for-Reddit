//
//  PostView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 24/03/23.
//

import SwiftUI

fileprivate struct CommentCard: View {
    
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
            
            Text(comment.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        
    }
    
}

fileprivate struct ClassicCommentView: View {
    
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

fileprivate struct LightCommentView: View {
    
    @ObservedObject var comment: Comment
    let level: Int
    @Binding var showReplies: Bool
    @Binding var mode: CommentsViewMode
    @Binding var order: CommentsOrder
    @Binding var loadingReplies: Bool
    
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
                    .transition(AnyTransition.slide)
                
                if comment.replies.more != nil && comment.replies.more!.count > 0 {
                    Button {
                        Task{
                            loadingReplies = true
                            comment.replies = await CommentsModel
                                .loadMoreReplies(listing: comment.replies,
                                                 count: 10,
                                                 sort: order,
                                                 linkId: comment.linkId,
                                                 parentId: comment.name!)
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
                    .padding(.leading, 8)
                    .disabled(loadingReplies)
                    
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
    
    @StateObject var comment: Comment
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
        
        VStack{
            ForEach(comments) { comment in
                
                CommentView(comment: comment, level: level, mode: $mode, order: $order)
                
            }
        }
        .animation(.easeInOut, value: comments)
        
        
    }
}

fileprivate struct PostCommentsView: View {
    
    @StateObject var model: CommentsModel
    //var model: ObservedObject<CommentsModel>
    @Binding var viewMode: CommentsViewMode
    @Binding var order: CommentsOrder
    @EnvironmentObject var post: Post
    @State var loadingMoreComments: Bool = false
    
    var body: some View {
        
        CommentsView(model.comments, mode: $viewMode, order: $order)
        
        if model.comments.more != nil && model.comments.more!.count > 0 {
            Button{
                Task {
                    loadingMoreComments = true
                    model.comments = await CommentsModel
                        .loadMoreReplies(listing: model.comments,
                                         count: 50,
                                         sort: order,
                                         linkId: post.name!,
                                         parentId: post.name!)
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
    @State private var commentsLoading: Bool = false
    @State private var loadingMoreComments: Bool = false
    
    
    init(post: Post, linkIsPresented: Binding<Bool>) {
        self.post = post
        self._linkIsPresented = linkIsPresented
        self._model = StateObject(wrappedValue: CommentsModel(postId: post.thingId!))
    }
    
    var body: some View {
        
        ScrollViewReader { reader in
            ScrollView {
                VStack(alignment: .leading){
                    
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
                        LinkAndThumbnailView(thumbnailUrl: post.thumbnailUrl, postUrl: post.url!)
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
                            showCommentsOrderPicker.toggle()
                        } label: {
                            HStack{
                                Label("Sort: \(commentsOrder.viewString)", systemImage: "arrow.up.arrow.down")
                                //Spacer()
                                Image(systemName: "chevron.right")
                                    .rotationEffect(showCommentsOrderPicker ? .degrees(90.0) : .degrees(0.0))
                            }
                        }
                        .disabled(commentsLoading)

                    }
                    
                    if showCommentsOrderPicker {
                        
                        CommentsOrderPicker(commentsOrder: $commentsOrder, showPicker: $showCommentsOrderPicker)
                            
                    }
                    
                    if commentsLoading {
                        HStack{
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.bottom, 10)
                    }
                    
                    PostCommentsView(model: model, viewMode: $commentsViewMode, order: $commentsOrder)
                        .environmentObject(post)
                    
                    
                    Spacer()
                }
                .padding([.leading, .trailing])
                .onChange(of: commentsOrder) { newOrder  in
                    Task {
                        commentsLoading = true
                        await model.load(sort: commentsOrder)
                        commentsLoading = false
                    }
                }
                
            }
            .animation(Animation.spring(), value: showCommentsOrderPicker)
            .animation(Animation.spring(), value: model.comments)
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
                commentsLoading = true
                await model.load(sort: commentsOrder)
                commentsLoading = false
            }
        }
        
        
        
    }
}

struct CommentsOrderPicker: View {
    
    @Binding var commentsOrder: CommentsOrder
    @Binding var showPicker: Bool
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0){
            
            ForEach(CommentsOrder.allCases, id: \.id) { item in
                
                Button(action: {
                    commentsOrder = item
                    showPicker.toggle()
                    
                }, label: {
                    VStack(spacing: 0) {
                        HStack{
                            
                            
                            Rectangle()
                                .foregroundColor(.clear)
                                .background {
                                    if item == commentsOrder {
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(.white, .blue)
                                    }
                                }
                                .frame(width: 16, height: 16)
                            
                            Text(item.viewString)
                                .padding(.leading)
                            
                            Spacer()
                            
                        }
                        .foregroundColor(.primary)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 10)
                        
                        if item != CommentsOrder.allCases.last{
                            Divider()
                        }
                        
                    }
                })
                
                
            }
            
        }
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        
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
        //PostView(post: Post(id: nil, name: nil, kind: "", data: postData), linkIsPresented: Binding.constant(false))
        
        CommentsOrderPicker(commentsOrder: Binding.constant(.top), showPicker: Binding.constant(true))
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
