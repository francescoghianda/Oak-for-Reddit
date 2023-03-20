//
//  SubredditItemView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import SwiftUI

struct SubredditIcon: View {
    
    let subreddit: Subreddit
    
    var body: some View {
        
        if let imageUrl = subreddit.iconImageUrl{
            AsyncImage(url: imageUrl) { phase in
                if let image = phase.image {
                    image.resizable()
                }
                else if (phase.error != nil){
                    Image("subreddit_noicon").resizable()
                }
                else {
                    ProgressView()
                }
            }
        }
        else {
            Image("subreddit_noicon").resizable()
        }
    }
}

struct SubredditItemView: View {
    
    let subreddit: Subreddit
    
    var body: some View {
        HStack{
            SubredditIcon(subreddit: subreddit)
                .scaledToFit()
                .frame(width: 70, height: 70, alignment: .center)
                .clipShape(Circle())
            
            Text(subreddit.displayName)
            Spacer()
        }
    }
}

struct SubredditItemView_Previews: PreviewProvider {
    static var previews: some View {
        SubredditItemView(subreddit: Subreddit.previewSubreddit)
    }
}
