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


struct PostListView: View {
    
    let subreddit: Subreddit?
    
    @State private var scrollViewOffset: CGFloat = .zero
    
    @StateObject var api: PostApi
    
    @State private var order: PostListingOrder = .new
    @State private var posts: Listing<Post>? = nil
    @State private var loading: Bool = true
    
    
    init(subreddit: Subreddit? = nil) {
        self.subreddit = subreddit
        self._api = StateObject(wrappedValue: PostApi(subreddit: subreddit))
        
    }
    
    var body: some View {
        
        ZStack{
            
            if let posts = posts {
                
                ScrollView {
                    
                    LazyVStack{
                    
                        if !loading {
                            ForEach(posts) { post in
                                Divider()
                                CompactPostCardView(post: post, showPin: order == .hot)
                            }

                            if(!posts.isEmpty){
                                Divider()
                                HStack{
                                    Spacer()
                                    if(posts.hasThingsAfter){
                                        ProgressView()
                                            .task {
                                                await api.loadMore(bind: $posts, order: order)
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
                                if(!posts.hasThingsAfter){
                                    Divider()
                                }
                                
                            }
                        }
                    }
                    .padding()
                }
                .listStyle(.plain)
                .navigationBarTitle(subreddit?.displayNamePrefixed ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: order, perform: { newValue in
                    loading = true
                })
                .toolbar {
                    
                    ToolbarItem {
                        OrderSelectorView(order: $order)
                    }
                    
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
                        await api.load(bind: $posts, order: order)
                        loading = false
                    }
            }
        }
        
        
        
        /*OffsettableScrollView { point in
            scrollViewOffset = point.y
            print("\(scrollViewOffset) - \(toolBarOpacity)")
        } content : {
                LazyVStack{

                    Color(hexString: subreddit.primaryColor)
                        .frame(height: 200)
                    HStack{
                        SubredditIcon(subreddit: subreddit, background: .white)
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 100, height: 100)
                            .overlay {
                                Circle().stroke(Color(hexString: subreddit.primaryColor), lineWidth: 4)
                            }
                            .offset(y: -60)
                            .padding(.bottom, -60)
                        Text(subreddit.displayNamePrefixed)
                            .font(.system(size: 30))
                            .padding(.leading)
                            .padding(.bottom, 20)
                    }
                    .padding(.bottom, 10)
                    
                    ForEach(1..<20) { index in
                        Rectangle()
                            .frame(width: .infinity, height: 100)
                            .foregroundColor(Color.blue)
                    }
                    
                    Spacer()
                    
                }
            }
            .navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack{
                        SubredditIcon(subreddit: subreddit, background: .white)
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 40, height: 40)
                        Text(subreddit.displayNamePrefixed)
                            .padding(.leading)
                    }
                    .opacity(toolBarOpacity)
                }
            }*/
        
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
