//
//  FavoritesSubredditsView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 13/04/23.
//

import SwiftUI

struct FavoritesSubredditsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.savingDate, order: .reverse)], animation: .spring())
    private var favorites: FetchedResults<SubredditEntity>
    
    @State var searchText: String = ""
    
    var sidebar: Bool = false
    @Binding var selected: String?
    
    var body: some View {
        
        let filtered = favorites.filter { subreddit in
            searchText.isEmpty || subreddit.displayName.localizedCaseInsensitiveContains(searchText)
        }
        
        if sidebar {
            
            //TextField("Search", text: $searchText)
            SearchBar(text: $searchText)
            
            if filtered.isEmpty {
                Text("There are no favorites :(")
                    .foregroundColor(.gray)
            }
            
            ForEach(filtered) { subreddit in
                
                NavigationLink(tag: subreddit.name, selection: $selected) {
                    PostListView(subreddit: Subreddit(entity: subreddit))
                } label: {
                    SubredditItemView(subreddit: subreddit, isFavorite: false, style: .sidebar)
                }
                .swipeActions {
                    Button(role: .destructive){
                        FavoriteSubreddits.remove(subreddit)
                    } label: {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                    }
                }
                
            }
            
            
        }
        else {
            
            ZStack {
                
                List(filtered) { subreddit in
                    
                    NavigationLink {
                        PostListView(subreddit: Subreddit(entity: subreddit))
                    } label: {
                        SubredditItemView(subreddit: subreddit, isFavorite: false)
                    }
                    .swipeActions {
                        Button(role: .destructive){
                            FavoriteSubreddits.remove(subreddit)
                        } label: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.white)
                        }
                    }
                    
                }
                .listStyle(.plain)
                .navigationTitle("Favorites")
                .searchable(text: $searchText)
                
                if filtered.isEmpty {
                    Text("There are no favorites :(")
                        .foregroundColor(.gray)
                }
            }
            
            
        }
        
        
    }
    
    func removeFavorite(_ subredditId: String) {
        
        if let entity = favorites.first(where: { entity in
            entity.thingId == subredditId
        })
        {
            
            viewContext.delete(entity)
            try? viewContext.save()
            
        }
        
    }
}

struct FavoritesSubredditsView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesSubredditsView(selected: Binding.constant(""))
    }
}
