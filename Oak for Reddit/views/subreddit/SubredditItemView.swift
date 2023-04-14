//
//  SubredditItemView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import SwiftUI

struct NsfwSymbolView: View{
    
    let color = Color(red: 255/255, green: 88/255, blue: 91/255)
    
    var body: some View {
        ZStack{
            Rectangle()
                .stroke(color, lineWidth: 3)
                .cornerRadius(2)
                .padding(.leading, 12)
                .padding(.trailing, 12)
                .padding(.top, 6)
                .padding(.bottom, 6)
            Text("nsfw")
                .foregroundColor(color)
                .font(.custom("Arial", size: 12))
        }
        .frame(width: 60, height: 30)
        .padding(.leading, -12)
        .padding(.trailing, -12)
        .padding(.top, -6)
        .padding(.bottom, -6)
    }
}

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
                    if subreddit.over18 {
                        /*Image("nsfw_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 18)*/
                        NsfwSymbolView()
                    }
                    Spacer()
                }
                //Image(systemName: "chevron.forward")
                
            }
            
        }
        .frame(height: height)
        //.border(.black)
    }
}

struct SubredditItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            SubredditItemView(subreddit: Subreddit.previewSubreddit)
            NsfwSymbolView()
        }
        .previewLayout(.sizeThatFits)
    }
}
