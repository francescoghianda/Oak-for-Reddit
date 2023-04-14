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
        
        NavigationView {
            
            List(subreddits) { subreddit in
                
                NavigationLink {
                    PostListView(subreddit: subreddit)
                } label: {
                    SubredditItemView(subreddit: subreddit)
                }
                
            }
            .navigationTitle("Favorites")
            
        }
        
    }
}

struct FavoritesSubredditsView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesSubredditsView()
    }
}
