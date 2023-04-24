//
//  SubredditItemView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import SwiftUI


struct SubredditIcon: View {
    
    let subreddit: Subreddit
    let background: Color?
    
    init(subreddit: Subreddit, background: Color? = nil){
        self.subreddit = subreddit
        self.background = background
    }
    
    var icon: some View {
        if let imageUrl = subreddit.iconImageUrl{
            return AnyView(AsyncImage(url: imageUrl) { phase in
                if let image = phase.image {
                    image.resizable()
                }
                else if (phase.error != nil){
                    Image("subreddit_noicon").resizable()
                }
                else {
                    ProgressView()
                }
            })
        }
        else {
            return AnyView(Image("subreddit_noicon").resizable())
        }
    }
    
    var body: some View {
        if let background = background {
            background
                .overlay {
                    icon
                }
        }
        else {
            icon
        }
    }
}

struct SubredditItemView: View {
    
    let subreddit: Subreddit
    
    let height: CGFloat = 80
    
    var isFavorite: Bool
    
    var body: some View {
        HStack(alignment: .center){
            SubredditIcon(subreddit: subreddit)
                .scaledToFit()
                .frame(width: height*0.8, height: height*0.8, alignment: .center)
                .clipShape(Circle())
            
            Text(subreddit.displayName)
                .padding(.leading)
            
            Spacer()
            
            ZStack{
                VStack(){
                    HStack{
                        if subreddit.over18 {
                            /*Image("nsfw_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 18)*/
                            NsfwSymbol()
                        }
                        if isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    Spacer()
                }
                //Image(systemName: "chevron.forward")
                
            }
            
        }
        .animation(.easeInOut, value: isFavorite)
        .frame(height: height)
        //.border(.black)
    }
}

struct SubredditItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            SubredditItemView(subreddit: Subreddit.previewSubreddit, isFavorite: true)
            NsfwSymbol()
        }
        .previewLayout(.sizeThatFits)
    }
}
