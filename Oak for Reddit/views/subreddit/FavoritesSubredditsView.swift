//
//  FavoritesSubredditsView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 13/04/23.
//

import SwiftUI

struct FavoritesSubredditsView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(entity: Subreddit.entity(), sortDescriptors: [], animation: .easeInOut)
    private var favorites: FetchedResults<Subreddit>
    
    @State var searchText: String = ""
    
    var sidebar: Bool = false
    @Binding var selected: String?
    
    var body: some View {
        
        
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
                
                NavigationLink(tag: subreddit.name, selection: $selected) {
                    PostListView(subredditNamePrefixed: subreddit.displayNamePrefixed)
                } label: {
                    //SubredditItemView(subreddit: subreddit, isFavorite: false)
                    Label {
                        Text(subreddit.displayName)
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
                        removeFavorite(subreddit)
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
                
                List(favorites.indices, id: \.self) { index in
                    
                    let subreddit = favorites[index]
                    
                    NavigationLink {
                        PostListView(subreddit: subreddit)
                    } label: {
                        SubredditItemView(subreddit: subreddit, isFavorite: false)
                    }
                    .swipeActions {
                        Button{
                            removeFavorite(subreddit)
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
                
                if favorites.isEmpty {
                    Text("There are no favorites :(")
                        .foregroundColor(.gray)
                }
            }
            
            
        }
        
        
    }
    
    func removeFavorite(_ entity: Subreddit) {
        
        moc.delete(entity)
                
        if moc.hasChanges {
            try? moc.save()
        }
        
    }
}

struct FavoritesSubredditsView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesSubredditsView(selected: Binding.constant(""))
    }
}
