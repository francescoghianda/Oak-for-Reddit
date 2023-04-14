//
//  Subreddits.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 17/03/23.
//

import SwiftUI
import CoreData

private struct OrderSelectorMenu: View {
    
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
    
    @StateObject var model = SubrettitListModel()
    
    @State var order: SubredditListingOrder = .normal
    @State var loading: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: SubredditEntity.entity(), sortDescriptors: [])
    private var favorites: FetchedResults<SubredditEntity>
    
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
                
        ZStack{
            
            NavigationView{
                ZStack{
                    
                    List {
                        ForEach(model.subreddits) { subreddit in
                            
                            let isFavorite = isFavorite(subreddit.subredditId)
                            
                            NavigationLink {
                                PostListView(subreddit: subreddit)
                            } label: {
                                SubredditItemView(subreddit: subreddit, isFavorite: isFavorite)
                            }
                            //.transition(.slide)
                            .swipeActions{
                                Button{
                                    if isFavorite {
                                        removeFavorite(subreddit.subredditId)
                                    }
                                    else {
                                        storeFavorite(subreddit)
                                    }
                                    
                                    //model.addFavourite(subreddit)
                                } label: {
                                    Image(systemName: isFavorite ? "trash.fill" : "star.fill")
                                        .foregroundColor(.white)
                                }
                                .tint(isFavorite ? .red : .yellow)
                            }

                        }
                        
                        if(!model.subreddits.isEmpty){
                            HStack{
                                Spacer()
                                if(model.subreddits.hasThingsAfter){
                                    ProgressView()
                                        .task {
                                            await model.loadMore(order: order)
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
                        loading = true
                        await model.load(order: order)
                        loading = false
                    }
                    .onChange(of: order) { newOrder in
                        Task {
                            loading = true
                            await model.load(order: newOrder)
                            loading = false
                        }
                    }
                    .opacity(loading ? 0 : 1)
                    
                    
                    if loading {
                        ProgressView()
                    }
                    
                }
                .navigationTitle("Subreddits")
                .toolbar {
                    ToolbarItem {
                        OrderSelectorMenu(toText: orderToText, order: $order)
                    }
                }
                
                
            }
            
            
            if(model.subreddits.isEmpty){
                ProgressView()
                    .task{
                        loading = true
                        await model.load(order: order)
                        loading = false
                    }
            }
        }
        
        
    }
    
    func isFavorite(_ subredditId: String) -> Bool {
        return favorites.contains(where: { entity in
            entity.id == subredditId
        })
    }
    
    func storeFavorite(_ subreddit: Subreddit) {
        
        if isFavorite(subreddit.subredditId) {
            return
        }
        
        subreddit.createEntity(context: viewContext)
        
        try? viewContext.save()
    }
    
    func removeFavorite(_ subredditId: String) {
        
        if let entity = favorites.first(where: { entity in
            entity.id == subredditId
        })
        {
            viewContext.delete(entity)
            try? viewContext.save()
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
