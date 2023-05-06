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
            
            Picker("", selection: $order) {
                
                ForEach(PostListingOrder.allCases, id: \.id) { item in
                    
                    switch item {
                    case .top, .controversial:
                        Menu {
                            
                            Picker("", selection: $order) {
                                
                                ForEach(TimeRange.allCases, id: \.id) { range in
                                    
                                    let tag: PostListingOrder = {
                                        if case .top = item {
                                            return .top(range: range)
                                        }
                                        else {
                                            return .controversial(range: range)
                                        }
                                    }()
                                    
                                    Text(range.rawValue)
                                        .tag(tag)
                                }
                                
                            }
                        } label: {
                            
                            Label {
                                
                                let showCheckmark: Bool = {
                                    if case .top = order, case .top = item{
                                        return true
                                    }
                                    if case .controversial = order, case .controversial = item {
                                        return true
                                    }
                                    return false
                                }()
                                
                                HStack {
                                    if showCheckmark {
                                        Image(systemName: "checkmark") // TODO: il checkmark non si vede
                                        Text("Selected")
                                    }
                                    Text(item.text)
                                }
                            } icon: {
                                Image(systemName: item.systemImage)
                            }

                        }

                    default:
                        Label(item.text, systemImage: item.systemImage)
                            .tag(item)
                    }
                    
                }
                
            }
            
            /*ForEach(PostListingOrder.allCases, id: \.id) { item in
                
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
                
            }*/

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


struct PostListView: View, Equatable {
    
    
    static func == (lhs: PostListView, rhs: PostListView) -> Bool {
        if let lsubr = lhs.subreddit, let rsubr = lhs.subreddit {
            return lsubr.name == rsubr.name
        }
        return true
    }
    
    
    let subreddit: Subreddit?
    let subredditNamePrefixed: String?
    let linkToSbubredditsAreActive: Bool
    
    @State private var scrollViewOffset: CGFloat = .zero
    @StateObject var model: PostListModel
    @State private var order: PostListingOrder = .best
    @State private var offset: CGPoint = .zero
    
    private let mediaSizeCache = MediaSizeCache()
    
    @State var linkIsPresented: Bool = false
    @State var navbarHeight: CGFloat = .zero
    @State private var contentWidth: CGFloat = .zero
    
    @State var loadingToastIsPresenting: Bool = false
    
    //@EnvironmentObject var userPreferences: UserPreferences
    @ObservedObject var userPreferences = UserPreferences.shared
    
    init(subreddit: Subreddit? = nil) {
        self.subreddit = subreddit
        self.subredditNamePrefixed = subreddit?.displayNamePrefixed
        self.linkToSbubredditsAreActive = subreddit == nil
        self._model = StateObject(wrappedValue: PostListModel(subredditNamePrefixed: subreddit?.displayNamePrefixed))
    }
    
    init(subredditNamePrefixed: String) {
        self.subreddit = nil
        self.subredditNamePrefixed = subredditNamePrefixed
        self.linkToSbubredditsAreActive = false
        self._model = StateObject(wrappedValue: PostListModel(subredditNamePrefixed: subredditNamePrefixed))
        
    }
    
    
    var body: some View {
                
        ZStack{
            
            if model.error == nil {
                
                ScrollView(showsIndicators: false) /*SPostListView*/ {
                    
                    LazyVStack {
                        
                        ForEach(model.posts) { post in
                            Divider()
                            
                            switch userPreferences.postsCardSize {
                            case .large:
                                LargePostCardView(post: post, showPin: order == .hot, mediaSize: mediaSizeCache[post.id], linkToSubredditIsActive: linkToSbubredditsAreActive, contentWidth: $contentWidth)
                            case .compact:
                                CompactPostCardView(post: post, showPin: order == .hot, linkToSubredditIsActive: linkToSbubredditsAreActive)
                            }
                            
                        }
                        //.opacity(postToShow != nil ? 0 : 1)
                        
                        Divider()

                        if(!model.posts.isEmpty){
                            HStack{
                                Spacer()
                                if(model.posts.hasThingsAfter){
                                    
                                    if userPreferences.loadNewPostsAutomatically {
                                        ProgressView()
                                            .onAppear {
                                                model.loadMore(order: order)
                                            }
                                    }
                                    else {
                                        
                                        if model.loadingMore {
                                            ProgressView()
                                        }
                                        else {
                                            Button {
                                                model.loadMore(order: order)
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
                    .disabled(model.loading)
                    .overlay {
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
                    .padding()
                    .offset(y: navbarHeight)
                    
                }
                
                
                if (!model.loading && model.posts.isEmpty){
                    Text("There is nothing here :(")
                        .foregroundColor(Color.gray)
                }
                
            }
            else {
                
                FetchErrorView(error: model.error!) {
                    model.load(order: order)
                }
                
            }
            
            
        }
        .navigationBarHidden(false)
        .navigationBarTitle(subredditNamePrefixed ?? String(localized: "Posts"), displayMode: .inline)
        .onChange(of: order) { newValue in
            //loading = true
            model.load(order: newValue)
        }
        .onChange(of: model.loading) { _ in
            loadingToastIsPresenting = model.loading
        }
        //.navigationBarHidden(postToShow != nil)
        .transition(.opacity)
        .toolbar {
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                
                OrderSelectorView(order: $order)
                
                Button {
                    model.load(order: order)
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(model.loading)


            }
            
        }
        .toast(isPresenting: $loadingToastIsPresenting, autoClose: false) {
            ProgressView()
        }
        .onFirstAppear {
            order = userPreferences.postPreferredOrder
            model.load(order: order)
        }
        
    }
}

struct CustomNavbar: View {
    
    @Binding var height: CGFloat
    
    var body: some View {
        
        VStack{
            
            HStack{
                Text("Posts")
                    .bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .overlay {
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            height = geo.size.height
                        }
                }
            }
            
            Spacer()
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

/*struct PostListView_Previews: PreviewProvider {
    static var previews: some View {
        //PostListView(subreddit: Subreddit.previewSubreddit)
    }
}*/
