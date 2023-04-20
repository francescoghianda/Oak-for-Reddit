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
    @State var loading: Bool = false
    
    @Environment(\.isSearching) private var isSearching
    @Environment(\.searchText) private var searchText
    
    @Environment(\.managedObjectContext) private var moc

    @FetchRequest(entity: SubredditEntity.entity(), sortDescriptors: [])
    private var favorites: FetchedResults<SubredditEntity>
    
    
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
                        if !isSearching {
                            loading = true
                            await model.load(order: order)
                            loading = false
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
                        OrderSelectorMenu(order: $order)
                    }
                }
                
                
            }
            
            if isSearching && model.subreddits.isEmpty && !loading {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 40, height: 40)
                    .scaledToFit()
            }
            else if !isSearching && model.isEmpty() {
                Color.clear
                    .task{
                        loading = true
                        await model.load(order: order)
                        loading = false
                    }
            }
        }
        .onSearchSubmit {
            Task {
                loading = true
                await model.search(sort: .relevance, query: searchText)
                loading = false
            }
        }
        .onFirstAppear {
            order = userPreferences.subredditsPreferredOrder
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
        
        subreddit.createEntity(context: moc)
        
        try? moc.save()
    }
    
    func removeFavorite(_ subredditId: String) {
        
        if let entity = favorites.first(where: { entity in
            entity.id == subredditId
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
