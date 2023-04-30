//
//  FavoritesSubredditsView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 13/04/23.
//

import SwiftUI

struct FavoritesSubredditsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: SubredditEntity.entity(), sortDescriptors: [], animation: .easeInOut)
    private var favorites: FetchedResults<SubredditEntity>
    
    @State var searchText: String = ""
    
    var sidebar: Bool = false
    @Binding var selected: String?
    
    var body: some View {
        
        let subreddits = favorites.map { entity in
            Subreddit(entity: entity)
        }
        .filter { subreddit in
            
            guard let _ = subreddit.displayName.range(of: searchText, options: .caseInsensitive)
            else {
                return searchText.isEmpty
            }
            
            return true
        }
        
        if sidebar {
            
            TextField("Search", text: $searchText)
            
            
            /*ForEach(subreddits.indices, id: \.self) { index in
                
                let subreddit = subreddits[index]
                
                NavigationLink(tag: subreddit.name, selection: $selected) {
                    PostListView(subreddit: subreddit)
                } label: {
                    SubredditItemView(subreddit: subreddit, isFavorite: false)
                }
                .swipeActions {
                    Button{
                        removeFavorite(subreddit.thingId)
                    } label: {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                    }
                    .tint(.red)
                }
                
            }*/
            //.animation(.easeInOut, value: subreddits)
            
            ForEach(favorites) { subreddit in
                
                NavigationLink(tag: subreddit.thingName!, selection: $selected) {
                    PostListView(subredditNamePrefixed: subreddit.displayNamePrefixed!)
                } label: {
                    //SubredditItemView(subreddit: subreddit, isFavorite: false)
                    Label {
                        Text(subreddit.displayName!)
                    } icon: {
                        AsyncImage(url: subreddit.iconImageUrl) { image in
                            image
                                .resizable()
                                .frame(width: 48, height: 48)
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                    }

                }
                .swipeActions {
                    Button{
                        removeFavorite(subreddit.thingId!)
                    } label: {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                    }
                    .tint(.red)
                }
                
            }
            
            
        }
        else {
            
            ZStack {
                
                List(subreddits.indices, id: \.self) { index in
                    
                    let subreddit = subreddits[index]
                    
                    NavigationLink {
                        PostListView(subreddit: subreddit)
                    } label: {
                        SubredditItemView(subreddit: subreddit, isFavorite: false)
                    }
                    .swipeActions {
                        Button{
                            removeFavorite(subreddit.thingId)
                        } label: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.white)
                        }
                        .tint(.red)
                    }
                    
                }
                .listStyle(.plain)
                .navigationTitle("Favorites")
                .searchable(text: $searchText)
                
                if subreddits.isEmpty {
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
