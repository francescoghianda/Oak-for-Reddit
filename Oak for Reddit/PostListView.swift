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
                
                let (symbol, text): (String, String) = {
                    switch item {
                    case .best:
                        return ("line.horizontal.star.fill.line.horizontal", "Best")
                    case .hot:
                        return ("flame", "Hot")
                    case .new:
                        return ("clock", "New")
                    case .rising:
                        return ("chart.line.uptrend.xyaxis", "Rising")
                    case .top:
                        return ("sparkle.magnifyingglass", "Top")
                    case .controversial:
                        return ("bolt.fill", "Controversial")
                    }
                }()
                
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
                        Label(text, systemImage: symbol)
                    }

                default:
                    Button {
                        $order.wrappedValue = item
                        //bindListing.wrappedValue = api.getListing(order: item)
                        
                    } label: {
                        Label(text, systemImage: symbol)
                    }
                }
                
            }

        } label: {
            Label("Order", systemImage: "arrow.up.arrow.down")
                //.labelStyle(.titleAndIcon)
        }
    }
}

struct PostStackView: View {
    
     // NOT IN USE
    
    @ObservedObject var api: PostApi
    @Binding var order: PostListingOrder
    @Binding var loading: Bool
    
    private let mediaSizeCache = MediaSizeCache()
    
    @Binding private var cardSize: CardSize
    
    var body: some View {
        
        VStack {
            if !loading {
                ForEach(api.posts!) { post in
                    Divider()
                    
                    switch cardSize {
                    case .large:
                        LargePostCardView(post: post, showPin: order == .hot, mediaSize: mediaSizeCache[post.uuid])
                    case .compact:
                        CompactPostCardView(post: post, showPin: order == .hot)
                    }
                    //.transition(.opacity)
                }
                
                Divider()

                if(!api.posts!.isEmpty){
                    HStack{
                        Spacer()
                        if(api.posts!.hasThingsAfter){
                            ProgressView()
                                .task {
                                    await api.loadMore(order: order)
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
        
        
    }
    
}

fileprivate enum CardSize: String, Codable {
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
    
    @State private var scrollViewOffset: CGFloat = .zero
    
    @StateObject var api: PostApi
    
    @State private var order: PostListingOrder = .new
    //@State private var posts: Listing<Post>? = nil
    @State private var loading: Bool = true
    
    @State private var offset: CGPoint = .zero
    
    private let mediaSizeCache = MediaSizeCache()
    
    @AppStorage("cardSize") private var cardSize: CardSize = CardSize.large
    
    init(subreddit: Subreddit? = nil) {
        self.subreddit = subreddit
        self._api = StateObject(wrappedValue: PostApi(subreddit: subreddit))
    }
    
    var body: some View {
        
        ZStack{
            
            if let posts = api.posts {
                
                ScrollView(showsIndicators: false) {
                    
                    LazyVStack {
                        if !loading {
                            ForEach(posts) { post in
                                Divider()
                                
                                switch cardSize {
                                case .large:
                                    LargePostCardView(post: post, showPin: order == .hot, mediaSize: mediaSizeCache[post.uuid])
                                case .compact:
                                    CompactPostCardView(post: post, showPin: order == .hot)
                                }
                                
                            }
                            
                            Divider()

                            if(!posts.isEmpty){
                                HStack{
                                    Spacer()
                                    if(posts.hasThingsAfter){
                                        Button {
                                            Task{
                                                await api.loadMore(order: order)
                                            }
                                        } label: {
                                            Text("Load more")
                                        }

                                        //ProgressView()
                                            /*.task {
                                                await api.loadMore(order: order)
                                            }*/
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
                .refreshable {
                    print("refresh")
                }
                
                
                /*List {
                    
                    if !loading {
                        ForEach(posts) { post in
                            
                            switch cardSize {
                            case .large:
                                LargePostCardView(post: post, showPin: order == .hot)
                            case .compact:
                                CompactPostCardView(post: post, showPin: order == .hot)
                            }
                        }

                        if(!posts.isEmpty){
                            HStack{
                                Spacer()
                                if(posts.hasThingsAfter){
                                    ProgressView()
                                        .task {
                                            await api.loadMore(order: order)
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
                            
                        }
                    }
                    
                }
                .buttonStyle(BorderlessButtonStyle())
                .listStyle(.plain)*/
                
                /*RefreshableScrollView {
                    
                    VStack{
                    
                        if !loading {
                            ForEach(posts) { post in
                                Divider()
                                LargePostCardView(post: post, showPin: order == .hot)
                            }

                            if(!posts.isEmpty){
                                Divider()
                                HStack{
                                    Spacer()
                                    if(posts.hasThingsAfter){
                                        ProgressView()
                                            /*.task {
                                                await api.loadMore(order: order)
                                            }*/
                                    }
                                    else{
                                        Text("You have reached the end")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                            .padding()
                                    }
                                    Spacer()
                                }
                                if(!posts.hasThingsAfter){
                                    Divider()
                                }
                                
                            }
                        }
                    }
                    .padding()
                    
                    
                }
                .onBottomReached {
                    
                    if(api.posts?.hasThingsAfter ?? false) {
                        await api.loadMore(order: order)
                    }
                    
                    
                }*/
                
                /*if(!loading) {
                    SPostListView{
                        PostStackView(api: api, order: $order, loading: $loading)
                    }
                }*/
                
                
                
                
                /*PostList {
                    
                    VStack{
                    
                        if !loading {
                            ForEach(posts) { post in
                                Divider()
                                LargePostCardView(post: post, showPin: order == .hot)
                            }

                            if(!posts.isEmpty){
                                Divider()
                                HStack{
                                    Spacer()
                                    if(posts.hasThingsAfter){
                                        ProgressView()
                                            /*.task {
                                                await api.loadMore(order: order)
                                            }*/
                                    }
                                    else{
                                        Text("You have reached the end")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                            .padding()
                                    }
                                    Spacer()
                                }
                                if(!posts.hasThingsAfter){
                                    Divider()
                                }
                                
                            }
                        }
                    }
                    .padding()
                    
                    
                }
                .onBottomReached {
                    
                    if(api.posts?.hasThingsAfter ?? false) {
                        await api.loadMore(order: order)
                    }
                    
                }*/
                
                /*ScrollView {
                    RefreshableView {
                        
                        VStack{
                        
                            if !loading {
                                ForEach(posts) { post in
                                    Divider()
                                    LargePostCardView(post: post, showPin: order == .hot)
                                }

                                if(!posts.isEmpty){
                                    Divider()
                                    HStack{
                                        Spacer()
                                        if(posts.hasThingsAfter){
                                            ProgressView()
                                                /*.task {
                                                    await api.loadMore(order: order)
                                                }*/
                                        }
                                        else{
                                            Text("You have reached the end")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                                .padding()
                                        }
                                        Spacer()
                                    }
                                    if(!posts.hasThingsAfter){
                                        Divider()
                                    }
                                    
                                }
                            }
                        }
                        .padding()
                        
                    }
                }
                .refreshable {
                    print("refreshing...")
                    
                    do {
                        try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
                    }
                    catch {
                        
                    }
                    
                    print("refreshed")
                    
                    //await api.load(order: order)
                }*/
                //.animation(.easeIn(duration: 1), value: posts)
                
                
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
        }
        .navigationBarTitle(subreddit?.displayNamePrefixed ?? "", displayMode: .inline)
        .onChange(of: order, perform: { newValue in
            loading = true
        })
        .toolbar {
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                
                OrderSelectorView(order: $order)
            
            
            
                Menu {
                    Button {
                        cardSize = .large
                    } label: {
                        Text("Large")
                    }
                    
                    Button {
                        cardSize = .compact
                    } label: {
                        Text("Compact")
                    }

                } label: {
                    
                    Image(systemName: "slider.horizontal.3")
                    
                }

                
            }
            
            
            
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
