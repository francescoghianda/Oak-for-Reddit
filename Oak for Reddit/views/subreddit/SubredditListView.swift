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
            
            Picker("Order", selection: order) {
                ForEach(SubredditListingOrder.allCases, id: \.id) { item in
                    Label(title: {Text(item.text)}, icon: {item.icon})
                        .foregroundColor(item.color)
                        .tag(item)
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
    @State private var loadingToastPresenting: Bool = false
        
    @Environment(\.isSearching) private var isSearching
    @Environment(\.searchText) private var searchText
    
    @Environment(\.managedObjectContext) private var moc

    @FetchRequest(entity: Subreddit.entity(), sortDescriptors: [])
    private var favorites: FetchedResults<Subreddit>
    
    
    var body: some View {
                
        ZStack{
            
            ZStack{
                
                List {
                    
                    ForEach(model.subreddits.indices, id: \.self) { index in
                        
                        let subreddit = model.subreddits[index]
                        let isFavorite = isFavorite(subreddit.thingId)
                        
                        NavigationLink {
                            PostListView(subreddit: subreddit)
                        } label: {
                            SubredditItemView(subreddit: subreddit, isFavorite: isFavorite)
                        }
                        .swipeActions{
                            Button{
                                if isFavorite {
                                    removeFavorite(subreddit)
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
                .id(model.uuid)
                .listStyle(.plain)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                .animation(.spring(), value: model.subreddits)
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
                .onChange(of: model.loading){ loading in
                    loadingToastPresenting = loading
                }
                .disabled(model.loading)
                .toast(isPresenting: $loadingToastPresenting, autoClose: false) {
                    ProgressView()
                }
                //.opacity(model.loading ? 0 : 1)
                
                
                /*if model.loading {
                    ProgressView()
                }*/
                
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
        
        try? subreddit.childContext?.save()
        
        if moc.hasChanges {
            try? moc.save()
        }
        
    }
    
    func removeFavorite(_ entity: Subreddit) {
        
        moc.delete(entity)
                
        if moc.hasChanges {
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
