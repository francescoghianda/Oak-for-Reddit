//
//  Subreddits.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 17/03/23.
//

import SwiftUI

private struct OrderSelectorView: View {
    
    //let api: SubrettitApi
    let toText: (SubredditListingOrder) -> String
    let order: Binding<SubredditListingOrder>
    //let bindListing: Binding<Listing<Subreddit>>
    
    var body: some View{
        
        Menu {
            
            ForEach(SubredditListingOrder.allCases, id: \.id) { item in
                
                let text: String = toText(item)
                
                let (symbol, color): (String, Color) = {
                    switch item {
                    case .normal:
                        return ("suit.club.fill", .green)
                    case .popular:
                        return ("flame", .red)
                    case .new:
                        return ("bolt.fill", .yellow)
                    }
                }()
                
                Button {
                    order.wrappedValue = item
                    //bindListing.wrappedValue = api.getListing(order: item)
                    
                } label: {
                    Label(text, systemImage: symbol)
                        .foregroundColor(color)
                }
                
            }

        } label: {
            Label("Order", systemImage: "arrow.up.arrow.down")
                //.labelStyle(.titleAndIcon)
        }
    }
}

struct SubredditListView: View {
    
    @StateObject var api = SubrettitApi(redditApi: RedditApi.shared)
    
    @State var order: SubredditListingOrder = .normal
    
    
    func orderToText(_ order: SubredditListingOrder) -> String {
        switch order {
        case .normal:
            return "Default"
        case .popular:
            return "Popular"
        case .new:
            return "New"
        }
    }
    
    var body: some View {
        
        let subreddits = api.getListing(order: order)
        
        ZStack{
            
            NavigationView{
                
                GeometryReader{ geometry in
                        List {
                            ForEach(subreddits) { subreddit in
                                NavigationLink {
                                    PostListView(subreddit: subreddit)
                                } label: {
                                    SubredditItemView(subreddit: subreddit)
                                }

                            }
                            
                            if(!subreddits.isEmpty){
                                HStack{
                                    Spacer()
                                    if(subreddits.hasThingsAfter){
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
                        .listStyle(.plain)
                        .refreshable{
                            await api.load(order: order)
                        }
                }
                .navigationTitle("\(orderToText(order)) subreddits")
                .toolbar {
                    ToolbarItem {
                        OrderSelectorView(toText: orderToText, order: $order)
                    }
                }
                
            }
            
            
            if(subreddits.isEmpty){
                ProgressView()
                    .task{
                        await api.load(order: order)
                    }
            }
        }
        
        
    }
}

class ScrollViewOffsetPreferenceKey: PreferenceKey{
    
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout Value, nextValue: () -> Value){
        value = nextValue()
    }
    
}

struct Subreddits_Previews: PreviewProvider {
    
    
    static var previews: some View {
        SubredditListView()
    }
}
