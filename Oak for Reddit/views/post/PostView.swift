//
//  PostView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 24/03/23.
//

import SwiftUI


struct PostView: View {
    
    @ObservedObject var userPreferences = UserPreferences.shared
    
    @ObservedObject var post: Post
    @StateObject var model: CommentsModel
    @State var commentsOrder: CommentsOrder = .confidence
    @State var showCommentsOrderPicker: Bool = false
    @State private var commentsViewMode: CommentsViewMode = .classic
    @State private var newCommentSheetPresenting: Bool = false
    @State private var newCommentStatus: NewCommentStatus = .canceled
    @State private var contentWidth: CGFloat = .zero
    
    init(service: CommentService = NetworkCommentService(), post: Post) {
        self.post = post
        self._model = StateObject(wrappedValue: CommentsModel(service: service, postId: post.thingId))
    }
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .center){
                
                HStack{
                    HStack(spacing: 0) {
                        Text("Posted by ")
                        Text("u/\(post.author) ⋅ \(post.getTimeSiceCreationFormatted())")
                    }
                        
                    Spacer()
                    
                    if post.over18 {
                        NsfwSymbol()
                            .padding(5)
                    }
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom)
                
                HStack {
                    Text(post.title)
                        .font(.headline)
                    Spacer()
                }
                
                if post.containsMedia {
                    PostMediaViewer(post: post, cornerRadius: 10, showContextMenu: true, width: $contentWidth)
                }
                else if post.postLinkType == .link {
                    
                    NavigationLink {
                        SafariView(url: post.url!)
                            .navigationBarHidden(true)
                    } label: {
                        LinkAndThumbnailView(thumbnailUrl: post.thumbnailUrl, postUrl: post.url!, contentWidth: $contentWidth)
                    }
                        
                }
                else if post.postLinkType == .poll {
                    PollView(pollData: post.pollData!)
                }
                    
                if !post.selfText.isEmpty {
                    SelfText(post.selfText)
                }
                
                HStack{
                    
                    Button {
                        post.vote(direction: .upvote)
                    } label: {
                        Image("arrowshape.up.fill")
                            .foregroundColor(post.upvoted ? .blue : .gray)
                    }
                    
                    Text(post.ups.toKNotation())
                        .font(.system(size: 12))
                    
                    Button {
                        post.vote(direction: .downvote)
                    } label: {
                        Image("arrowshape.up.fill")
                            .rotationEffect(.degrees(180))
                            .foregroundColor(post.downvoted ? .red : .gray)
                    }
                    
                    HStack{
                        Image(systemName: "message.fill")
                        Text("\(post.numComments)")
                            .font(.system(size: 12))
                        if post.locked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color.yellow)
                        }
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                .padding(.top)
                .foregroundColor(Color.gray)
                
                HStack(spacing: 20){
                    Text("Comments")
                        .font(.title)
                        .padding([.top, .bottom])
                    Spacer()
                    
                    LoggedActionButton {
                        newCommentSheetPresenting = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .disabled(post.locked)
                    
                    Button {
                        showCommentsOrderPicker.toggle()
                    } label: {
                        HStack{
                            Label(LocalizedStringKey(commentsOrder.text), systemImage: "arrow.up.arrow.down")
                            //Spacer()
                            Image(systemName: "chevron.right")
                                .rotationEffect(showCommentsOrderPicker ? .degrees(90.0) : .degrees(0.0))
                        }
                    }
                    
                }
                .disabled(model.loading)
                
                if showCommentsOrderPicker {
                    
                    CommentsOrderPicker(commentsOrder: $commentsOrder, showPicker: $showCommentsOrderPicker)
                        
                }
                
                if model.loading {
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
            .background {
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            contentWidth = geo.size.width
                        }
                        .onChange(of: geo.size.width) { newWidth in
                            contentWidth = newWidth
                        }
                }
            }
            .padding([.leading, .trailing])
            .onChange(of: commentsOrder) { newOrder  in
                model.load(sort: newOrder)
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

            }
            
        }
        .onFirstAppear {
            commentsViewMode = userPreferences.commentsViewMode
            commentsOrder = userPreferences.commentsPreferredOrder
            
            model.load(sort: commentsOrder)
        }
        .sheet(isPresented: $newCommentSheetPresenting, onDismiss: {
            
            if case .submitted(let comment) = newCommentStatus {
                var children = model.comments.children
                children.insert(comment, at: 0)
                model.comments = Listing(before: model.comments.before, after: model.comments.after, children: children, more: model.comments.more)
            }
            
        }, content: {
            NewCommentForm(parentId: post.name, status: $newCommentStatus)
        })
        
    }
}


struct PostView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            PostView(service: MockCommentService(), post: PostsPreviewData.post)
        }
        .navigationViewStyle(.stack)
    }
}
