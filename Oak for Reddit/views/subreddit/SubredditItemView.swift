//
//  SubredditItemView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import SwiftUI

enum SubredditCardStyle{
    case standard, sidebar
}

struct SubredditIcon: View {
    
    let subreddit: SubredditProtocol
    let background: Color?
    
    init(subreddit: SubredditProtocol, background: Color? = nil){
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
    
    let subreddit: SubredditProtocol
    var isFavorite: Bool
    var style: SubredditCardStyle = .standard
    
    var body: some View {
        HStack(alignment: .center){
            
            let size = CGFloat(style == .standard ? 64 : 48)
            let paddingEdges: Edge.Set = style == .standard ? [.leading, .trailing, .top, .bottom] : [.trailing]
            
            SubredditIcon(subreddit: subreddit)
                .scaledToFit()
                .frame(width: size, height: size, alignment: .center)
                .clipShape(Circle())
                .padding(paddingEdges, 10)
            
            Text(subreddit.displayName)
            
            Spacer()
            
            ZStack{
                VStack(){
                    HStack{
                        if subreddit.over18 {
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
        //.animation(.easeInOut, value: isFavorite)
        //.frame(height: height)
        //.border(.black)
    }
}

struct SubredditItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            //SubredditItemView(subreddit: Subreddit.previewSubreddit, isFavorite: true)
            NsfwSymbol()
        }
        .previewLayout(.sizeThatFits)
    }
}
