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
    
    //@EnvironmentObject var userPreferences: UserPreferences
    @ObservedObject var userPreferences = UserPreferences.shared
    
    @StateObject var model = SubrettitListModel()
    
    @State var order: SubredditListingOrder = .normal
    @State private var loadingToastPresenting: Bool = false
        
    @Environment(\.isSearching) private var isSearching
    @Environment(\.searchText) private var searchText
    
    @Environment(\.managedObjectContext) private var moc

    @FetchRequest(entity: SubredditEntity.entity(), sortDescriptors: [])
    private var favorites: FetchedResults<SubredditEntity>
    
    
    @ViewBuilder
    var subredditCards: some View {
        ForEach(model.subreddits.indices, id: \.self) { index in
            
            let subreddit = model.subreddits[index]
            let isFavorite = isFavorite(subreddit.thingId)
            
            NavigationLink {
                PostListView(subreddit: subreddit)
            } label: {
                SubredditItemView(subreddit: subreddit, isFavorite: isFavorite)
            }
            .isDetailLink(true)
            .swipeActions{
                Button {
                    if isFavorite {
                        removeFavorite(subreddit.thingId)
                    }
                    else {
                        FavoriteSubreddits.add(subreddit)
                    }
                    
                } label: {
                    Image(systemName: isFavorite ? "trash.fill" : "star.fill")
                        .foregroundColor(.white)
                }
                .tint(isFavorite ? .red : .yellow)
            }

        }
    }
    
    var body: some View {
                
        ZStack{
            
            List {
                
                if model.error == nil {
                    
                    subredditCards
                    
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
            .disabled(model.loading)
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
            .toast(isPresenting: $loadingToastPresenting, autoClose: false) {
                ProgressView()
            }
            .navigationTitle("Subreddits")
            .toolbar {
                ToolbarItem {
                    OrderSelectorMenu(order: $order)
                }
            }
            
            if let error = model.error {
                FetchErrorView(error: error)
            }
            
            if isSearching && model.subreddits.isEmpty && !model.loading && model.error == nil {
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
    
    
    func removeFavorite(_ subredditId: String) {
        
        if let entity = favorites.first(where: { entity in
            entity.thingId == subredditId
        })
        {
            FavoriteSubreddits.remove(entity)
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
