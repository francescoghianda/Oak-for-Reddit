//
//  LargePostCardView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 28/03/23.
//

import SwiftUI
import AVKit

struct LinkAndThumbnailView: View {
    
    let thumbnailUrl: URL?
    let postUrl: URL
    @Binding var contentWidth: CGFloat
    
    //@Environment(\.colorScheme) var colorScheme
    
    private let labelHeight = CGFloat(45)
    
    var body: some View {
        
        if let thumbnailUrl = thumbnailUrl {
            
            let width = contentWidth * 0.7
            let height = width * 0.6
            
            VStack {
                
                AsyncImage(url: thumbnailUrl) { image in
                    
                    image
                        .resizable()
                        .scaledToFill()
                    
                } placeholder: {
                    ProgressView()
                        .offset(y: -(labelHeight/2))
                }
                
            }
            .frame(width: width, height: height)
            .background(.ultraThinMaterial)
            .overlay{
                VStack{
                    
                    Spacer()
                    
                    Label("\(postUrl)", systemImage: "link")
                        .foregroundColor(.orange)
                        .lineLimit(1)
                        .padding(10)
                        //.frame(width: width, height: labelHeight)
                        .frame(width: width, height: labelHeight)
                        .background(.ultraThinMaterial)
                        
                    
                }
                .frame(maxWidth: .infinity)
                
            }
            .cornerRadius(10)
            
        }
        else {
            
            HStack(spacing: 0){
                Image(systemName: "link")
                    .foregroundColor(.orange)
                    .padding()
                Divider()
                Text("\(postUrl)")
                    .lineLimit(1)
                    .foregroundColor(.orange)
                    .padding()
            }
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .padding()
            
            
        }
        
        
    }
}

struct LinkAndThumbnailView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        LinkAndThumbnailView(thumbnailUrl: URL(string: "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg"), postUrl: URL(string: "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg")!, contentWidth: Binding.constant(400))
            .previewLayout(.sizeThatFits)
        
    }
}


struct SelfText: View {
    
    let text: String
    let lineLimit: Int? = 10
    let expandedLineLimit: Int? = 40
    
    @State private var expanded: Bool = false
    @State private var truncated: Bool = false
    
    init(_ text: String){
        self.text = text
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0){
            
            Text(LocalizedStringKey(text))
                .padding()
                .lineLimit(expanded ? expandedLineLimit : lineLimit)
                .background {
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            self.determineTruncation(geometry)
                        }
                    }
                }
            
            
            if truncated && !expanded {
                Divider()
                HStack{
                    Spacer()
                    Button("Show more") {
                        withAnimation {
                            expanded = true
                        }
                    }
                    .padding()
                    Spacer()
                }
                
            }
            
            if expanded {
                Divider()
                HStack{
                    Spacer()
                    Button("Hide") {
                        withAnimation {
                            expanded = false
                        }
                    }
                    .padding()
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        
        
    }
    
    private func determineTruncation(_ geometry: GeometryProxy) {
        
        let total = self.text.boundingRect(
            with: CGSize(
                width: geometry.size.width,
                height: .greatestFiniteMagnitude
            ),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 16)],
            context: nil
        )
        
        if total.size.height > geometry.size.height {
            self.truncated = true
        }
    }
    
}

struct LargePostCardView: View {
    
    @EnvironmentObject var userPreferences: UserPreferences
    
    @ObservedObject var post: Post
    let showPin: Bool
    @StateObject var mediaSize: MediaSize
    let linkToSubredditIsActive: Bool
    @Binding var contentWidth: CGFloat
        
    //@State var linkIsPresented: Bool = false
    @State private var showMedia: Bool = false
    @State private var maxY: CGFloat = .zero
    @State private var selfTextLineLimit: Int = 10
    
    var body: some View {

        
        VStack(spacing: 0){
            
            HStack{
                
                if post.stickied && showPin {
                    Image(systemName: "pin.fill")
                        .foregroundColor(Color.green)
                        .rotationEffect(.degrees(45))
                        .padding(5)
                        
                    Text("PINNED BY MODERATORS")
                        .foregroundColor(Color.gray)
                        .bold()
                        .font(.system(size: 10))
                }
                
                Spacer()
                
            }
            
            VStack{
                VStack{
                    
                    NavigationLink {
                        PostView(post: post)
                    } label: {
                       
                        ZStack(alignment: .leading){
                            
                            Rectangle()
                                .foregroundColor(.clear)
                                .contentShape(Rectangle())
                                .frame(idealWidth: .infinity)
                            
                            HStack {
                                Text(post.title)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .frame(maxHeight: 60)
                                
                                Spacer()
                                
                                if post.over18 {
                                    NsfwSymbol()
                                        .padding(5)
                                }
                            }
                        }

                    }
                    .buttonStyle(.plain)
                    .padding([.top, .bottom], 10)
                    

                    if post.postLinkType == .permalink || post.postLinkType == .nolink { // self post
                        
                        if !post.selfText.isEmpty {
                            SelfText(post.selfText)
                                .padding(.bottom)
                        }
                        
                    }
                    else if post.postLinkType == .link { // external link
                        
                        NavigationLink {
                            SafariView(url: post.url!)
                                .navigationBarHidden(true)
                        } label: {
                            LinkAndThumbnailView(thumbnailUrl: post.thumbnailUrl, postUrl: post.url!, contentWidth: _contentWidth)
                                .padding(.bottom)
                        }
                        
                    }
                    else if post.postLinkType == .poll {
                        PollView(pollData: post.pollData!)
                            .padding(.bottom)
                    }
                    else {
                        
                        PostMediaViewer(post: post, cornerRadius: 10, showContextMenu: true, width: $contentWidth)
                            .padding(.bottom)
                    }
                    
                }
                    
                HStack{
                    Button {
                        post.vote(dir: .upvote)
                    } label: {
                     Image("arrowshape.up.fill")
                            .foregroundColor(post.upvoted ? Color.blue : Color.gray)
                    }
                    
                    Text(post.ups.toKNotation())
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                    
                    Button {
                        post.vote(dir: .downvote)
                    } label: {
                        Image("arrowshape.up.fill")
                            .rotationEffect(.degrees(180))
                            .foregroundColor(post.downvoted ? Color.red : Color.gray)
                            //.padding(.leading, 5)
                    }
                    
                    NavigationLink {
                        PostView(post: post)
                    } label: {
                        HStack{
                            Image(systemName: "message.fill")
                            Text("\(post.numComments.toKNotation())")
                                .font(.system(size: 12))
                            if post.locked {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color.yellow)
                            }
                        }
                    }
                    .padding(.leading)
                    .foregroundColor(Color.gray)
                    
                    Spacer()
                    
                    Text(post.getTimeSiceCreationFormatted())
                        .foregroundColor(Color.gray)
                        .font(.system(size: 12))
                        .bold()
                    
                    Text("·")
                        .foregroundColor(Color.gray)
                    
                    NavigationLink {
                        PostListView(subredditNamePrefixed: "r/\(post.subreddit)")
                    } label: {
                        Text(post.subreddit)
                            .font(.system(size: 14))
                            .foregroundColor(Color.gray)
                    }
                    .disabled(!linkToSubredditIsActive)
                    
                    
                }
                .lineLimit(1)
            }
        }
    
    
    }
    
}



/*struct LargePostCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        LargePostCardView(post: PostsPreviewData.post, showPin: true)
            .previewLayout(.sizeThatFits)
    }
}*/
