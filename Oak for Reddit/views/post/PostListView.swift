//
//  PostListView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 21/03/23.
//

import SwiftUI

private struct OrderSelectorView: View {
    
    @Binding var order: PostListingOrder
    
    var body: some View {
        
        Menu {
            
            ForEach(PostListingOrder.allCases, id: \.id) { item in
                
                switch item {
                case .top, .controversial:
                    Menu {
                        ForEach(TimeRange.allCases, id: \.id) { range in
                            Button {
                                if case .top = item {
                                    $order.wrappedValue = .top(range: range)
                                }
                                else {
                                    $order.wrappedValue = .controversial(range: range)
                                }
                            } label: {
                                Text(range.rawValue)
                            }
                        }
                    } label: {
                        Label(item.text, systemImage: item.systemImage)
                    }

                default:
                    Button {
                        $order.wrappedValue = item
                        //bindListing.wrappedValue = api.getListing(order: item)
                        
                    } label: {
                        Label(item.text, systemImage: item.systemImage)
                    }
                }
                
            }

        } label: {
            Label("Order", systemImage: "arrow.up.arrow.down")
                //.labelStyle(.titleAndIcon)
        }
    }
}

@objc public enum PostCardSize: Int, Codable {
    case large, compact
}

class MediaSize: ObservableObject {
    
    @Published var size: CGSize = .zero
    
}

class MediaSizeCache {
    
    private var cache: [String : MediaSize] = [:]
    
    subscript(postUUID: String) -> MediaSize {
        
        get {
            
            if let size = cache[postUUID] {
                return size
            }
            
            let size = MediaSize()
            cache[postUUID] = size
            return size
            
        }
        
        set(newSize) {
            
            cache[postUUID] = newSize
            
        }
        
    }
    
}


struct PostListView: View {
    
    let subreddit: Subreddit?
    let subredditNamePrefixed: String?
    let linkToSbubredditsAreActive: Bool
    
    @State private var scrollViewOffset: CGFloat = .zero
    
    @StateObject var api: PostListModel
    
    @State private var order: PostListingOrder = .best
    //@State private var posts: Listing<Post>? = nil
    @State private var loading: Bool = true
    @State private var loadingMore: Bool = false
    
    @State private var offset: CGPoint = .zero
    
    private let mediaSizeCache = MediaSizeCache()
    
    //@Namespace var namespace
    //@State var postToShow: Post? = nil
    @State var linkIsPresented: Bool = false
    
    //@AppStorage("cardSize") private var cardSize: PostCardSize = PostCardSize.large
    
    @EnvironmentObject var userPreferences: UserPreferences
    
    init(subreddit: Subreddit? = nil) {
        self.subreddit = subreddit
        self.subredditNamePrefixed = subreddit?.displayNamePrefixed
        self.linkToSbubredditsAreActive = subreddit == nil
        self._api = StateObject(wrappedValue: PostListModel(subredditNamePrefixed: subreddit?.displayNamePrefixed))
    }
    
    init(subredditNamePrefixed: String) {
        self.subreddit = nil
        self.subredditNamePrefixed = subredditNamePrefixed
        self.linkToSbubredditsAreActive = false
        self._api = StateObject(wrappedValue: PostListModel(subredditNamePrefixed: subredditNamePrefixed))
    }
    
    
    var body: some View {
                
        ZStack{
            
                
            if let posts = api.posts {
                
                ScrollView(showsIndicators: false) {
                    
                    LazyVStack {
                        if !loading {
                            ForEach(posts) { post in
                                Divider()
                                
                                switch userPreferences.postsCardSize {
                                case .large:
                                    LargePostCardView(post: post, showPin: order == .hot, mediaSize: mediaSizeCache[post.uuid], linkToSubredditIsActive: linkToSbubredditsAreActive)
                                case .compact:
                                    CompactPostCardView(post: post, showPin: order == .hot, linkToSubredditIsActive: linkToSbubredditsAreActive)
                                }
                                
                                
                            }
                            //.opacity(postToShow != nil ? 0 : 1)
                            
                            Divider()

                            if(!posts.isEmpty){
                                HStack{
                                    Spacer()
                                    if(posts.hasThingsAfter){
                                        
                                        if userPreferences.loadNewPostsAutomatically {
                                            ProgressView()
                                                .task {
                                                    loadingMore = true
                                                    await api.loadMore(order: order)
                                                    loadingMore = false
                                                }
                                        }
                                        else {
                                            
                                            if loadingMore {
                                                ProgressView()
                                            }
                                            else {
                                                Button {
                                                    Task{
                                                        loadingMore = true
                                                        await api.loadMore(order: order)
                                                        loadingMore = false
                                                    }
                                                } label: {
                                                    Text("Load more")
                                                }
                                            }
                                            
                                            
                                        }

                                        
                                    }
                                    else{
                                        Text("You have reached the end")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                            .padding()
                                    }
                                    Spacer()
                                }
                                
                                Divider()
                                
                            }
                        }
                    }
                    .padding()
                    
                }
                
                
                if (!loading && posts.isEmpty){
                    Text("There is nothing here :(")
                        .foregroundColor(Color.gray)
                }
                
            }
            
            if(loading){
                ProgressView()
                    .task{
                        loading = true
                        await api.load(order: order)
                        loading = false
                    }
            }
            
                    
                
            /*if let postToShow = postToShow {
                PostView(post: postToShow, linkIsPresented: $linkIsPresented, namespace: namespace, postToShow: $postToShow)
            }*/
            
            
            
            
        }
        .navigationBarTitle(subredditNamePrefixed ?? "Posts", displayMode: .inline)
        .onChange(of: order, perform: { newValue in
            loading = true
        })
        //.navigationBarHidden(postToShow != nil)
        .transition(.opacity)
        .toolbar {
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                
                OrderSelectorView(order: $order)

            }
            
        }
        .onFirstAppear {
            order = userPreferences.postPreferredOrder
        }
        
    }
}

struct OffsettableScrollView<T: View>: View {

    let axes: Axis.Set
    let showsIndicator: Bool
    let onOffsetChanged: (CGPoint) -> Void
    let content: T
    
    init(axes: Axis.Set = .vertical, showsIndicator: Bool = true, onOffsetChanged: @escaping (CGPoint) -> Void = { _ in }, @ViewBuilder content: () -> T) {
        
        self.axes = axes
        self.showsIndicator = showsIndicator
        self.onOffsetChanged = onOffsetChanged
        self.content = content()
    }

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicator) {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: OffsetPreferenceKey.self,
                            value: proxy.frame(
                                in: .named("ScrollViewOrigin")
                            ).origin
                        )
                    }
                    .frame(width: 0, height: 0)
                    content
                }
                .coordinateSpace(name: "ScrollViewOrigin")
                .onPreferenceChange(OffsetPreferenceKey.self,
                                    perform: onOffsetChanged)
    }
}

private struct OffsetPreferenceKey: PreferenceKey{
    
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
}

struct PostListView_Previews: PreviewProvider {
    static var previews: some View {
        PostListView(subreddit: Subreddit.previewSubreddit)
    }
}
