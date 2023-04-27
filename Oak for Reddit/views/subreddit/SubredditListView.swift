//
//  Subreddits.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 17/03/23.
//

import SwiftUI
import CoreData

private struct OrderSelectorMenu: View {
    
    let order: Binding<SubredditListingOrder>
    
    var body: some View{
        
        Menu {
            
            ForEach(SubredditListingOrder.allCases, id: \.id) { item in
                
                Button {
                    order.wrappedValue = item
                    
                } label: {
                    Label(title: {Text(item.text)}, icon: {item.icon})
                        .foregroundColor(item.color)
                }
                
            }

        } label: {
            Label("Order", systemImage: "arrow.up.arrow.down")
        }
    }
}

struct SubredditListView: View {
    
    @EnvironmentObject var userPreferences: UserPreferences
    
    @StateObject var model = SubrettitListModel()
    
    @State var order: SubredditListingOrder = .normal
    
    @Environment(\.isSearching) private var isSearching
    @Environment(\.searchText) private var searchText
    
    @Environment(\.managedObjectContext) private var moc

    @FetchRequest(entity: SubredditEntity.entity(), sortDescriptors: [])
    private var favorites: FetchedResults<SubredditEntity>
    
    
    var body: some View {
                
        ZStack{
            
            ZStack{
                
                List {
                    
                    ForEach(model.subreddits) { subreddit in
                        
                        let isFavorite = isFavorite(subreddit.thingId)
                        
                        NavigationLink {
                            PostListView(subreddit: subreddit)
                        } label: {
                            SubredditItemView(subreddit: subreddit, isFavorite: isFavorite)
                        }
                        //.transition(.slide)
                        .swipeActions{
                            Button{
                                if isFavorite {
                                    removeFavorite(subreddit.thingId)
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
                                    .onAppear {
                                        model.loadMore(order: order)
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
                //.animation(.spring(), value: model.subreddits)
                .refreshable{
                    if !isSearching {
                        model.load(order: order)
                    }
                }
                .onChange(of: isSearching, perform: { isSearching in
                    
                    if isSearching {
                        model.save()
                    }
                    else {
                        model.restore()
                    }
                    
                })
                .onChange(of: order) { newOrder in
                    model.load(order: newOrder)
                }
                .opacity(model.loading ? 0 : 1)
                
                
                if model.loading {
                    ProgressView()
                }
                
            }
            .navigationTitle("Subreddits")
            .toolbar {
                ToolbarItem {
                    OrderSelectorMenu(order: $order)
                }
            }
            
            if isSearching && model.subreddits.isEmpty && !model.loading {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 40, height: 40)
                    .scaledToFit()
            }
            else if !isSearching && model.isEmpty() {
                Color.clear
                    .onAppear{
                        model.load(order: order)
                    }
            }
        }
        .onSearchSubmit {
            model.search(sort: .relevance, query: searchText)
        }
        .onFirstAppear {
            order = userPreferences.subredditsPreferredOrder
        }
        
        
    }
    
    func isFavorite(_ subredditId: String) -> Bool {
        return favorites.contains(where: { entity in
            entity.thingId == subredditId
        })
    }
    
    func storeFavorite(_ subreddit: Subreddit) {
        
        if isFavorite(subreddit.thingId) {
            return
        }
        
        subreddit.createEntity(context: moc)
        
        try? moc.save()
    }
    
    func removeFavorite(_ subredditId: String) {
        
        if let entity = favorites.first(where: { entity in
            entity.thingId == subredditId
        })
        {
            moc.delete(entity)
            try? moc.save()
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
