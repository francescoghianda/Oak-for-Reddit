//
//  PostView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 24/03/23.
//

import SwiftUI


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