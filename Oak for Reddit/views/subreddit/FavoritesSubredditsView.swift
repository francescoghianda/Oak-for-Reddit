//
//  FavoritesSubredditsView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 13/04/23.
//

import SwiftUI

struct FavoritesSubredditsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: SubredditEntity.entity(), sortDescriptors: [])
    private var favorites: FetchedResults<SubredditEntity>
    
    var body: some View {
        
        let subreddits = favorites.map { entity in
            Subreddit(entity: entity)
        }
        
        ZStack {
            
            NavigationView {
                
                List(subreddits) { subreddit in
                    
                    NavigationLink {
                        PostListView(subreddit: subreddit)
                    } label: {
                        SubredditItemView(subreddit: subreddit, isFavorite: false)
                    }
                    .swipeActions {
                        Button{
                            removeFavorite(subreddit.subredditId)
                        } label: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.white)
                        }
                        .tint(.red)
                    }
                    
                }
                .listStyle(.plain)
                .navigationTitle("Favorites")
                
            }
            
            if subreddits.isEmpty {
                Text("There are no favorites :(")
                    .foregroundColor(.gray)
            }
        }
        
        
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

struct FavoritesSubredditsView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesSubredditsView()
    }
}
