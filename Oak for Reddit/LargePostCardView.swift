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
    
    @Environment(\.colorScheme) var colorScheme
    
    private let width = UIScreen.main.bounds.width * 0.7
    private let height = (UIScreen.main.bounds.width * 0.7) * 0.6
    
    var body: some View {
        
        if let thumbnailUrl = thumbnailUrl {
            
            AsyncImage(url: thumbnailUrl) { image in
                
                image
                    .resizable()
                    .scaledToFill()

                
            } placeholder: {
                ProgressView()
            }
            .overlay{
                VStack{
                    
                    Spacer()
                    
                    Label("\(postUrl)", systemImage: "link")
                        .foregroundColor(.orange)
                        .lineLimit(1)
                        .padding(10)
                        .frame(width: width)
                        .background(.ultraThinMaterial)
                        
                    
                }
                .frame(width: .infinity)
                
            }
            .frame(width: width, height: height)
            .cornerRadius(10)
            
        }
        else {
            
            Label {
                Text("\(postUrl)")
                    .lineLimit(1)
                    .foregroundColor(.orange)
            } icon: {
                Image(systemName: "link")
                    .foregroundColor(.orange)
            }
            .frame(width: .infinity)
            .padding()
            
        }
        
        
    }
}

struct LinkAndThumbnailView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        LinkAndThumbnailView(thumbnailUrl: URL(string: "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg"), postUrl: URL(string: "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg")!)
            .previewLayout(.sizeThatFits)
        
    }
}

/*struct PostContentView: View {
    
    let post: Post
    @Binding var linkIsPresented: Bool
    
    @State var showImageOverlay: Bool = false
    @State var imageSaved: Bool = false
    
    var body: some View {
        
        
        if post.postLinkType == .image {
            
            AsyncUIImage(url: post.url) { (image, error) in
                
                if let image = image {
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10, antialiased: true)
                        .overlay {
                            
                            VStack {
                                
                                HStack{
                                    
                                    Button {
                                        
                                        ImageSaver {
                                            withAnimation {
                                                imageSaved = true
                                            }
                                        }
                                        .saveImage(image: image)
                                        
                                    } label: {
                                        
                                        Image(systemName: "square.and.arrow.down")
                                            .foregroundColor(.white)
                                            .offset(y: showImageOverlay ? 0 : -20)
                                        
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                
                                Spacer()
                            }
                            .background(LinearGradient(colors: [Color.black.opacity(0.8), Color.clear], startPoint: .top, endPoint: .bottom))
                            .opacity(showImageOverlay ? 1 : 0)
                            
                        }
                        .onTapGesture {
                            
                            withAnimation {
                                showImageOverlay.toggle()
                            }
                            
                        }
                        /*.matchedGeometryEffect(id: post.uuid, in: mediaSheetNamespace, isSource: true)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showMedia.toggle()
                            }
                        }*/
                }
                else if error != nil {
                    Label {
                        Text("Error loading image")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }

                }
                else {
                    ProgressView()
                        .padding()
                }
                
            }
            
            
        }
        else if (post.postLinkType == .media || post.postLinkType == .video), let media = post.media {
            
            switch media {
            case .redditVideo(let data):
                RedditVideoPlayer(url: data.hlsUrl!)
                    .scaledToFit()
                    .cornerRadius(10, antialiased: true)
                
            case .embed(let data):
                EmbedVideoPlayer(media: data)
                    .frame(idealWidth: CGFloat(data.width), idealHeight: CGFloat(data.height))
                    .scaledToFit()
                    .cornerRadius(10, antialiased: true)
                    
            case .unknown:
                Rectangle()
            }
            
        }
        else if post.postLinkType == .link {
            
            Button {
                linkIsPresented = true
            } label: {
                LinkAndThumbnailView(thumbnailUrl: post.thumbnailUrl, postUrl: post.url)
            }
            
        }
        else {
            Text("Internal link")
        }
        
    }
}*/

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
        
        VStack{
            Text(LocalizedStringKey(text))
                .lineLimit(expanded ? expandedLineLimit : lineLimit)
                .background {
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            self.determineTruncation(geometry)
                        }
                    }
                }
            
            if truncated && !expanded {
                Button("Show more") {
                    withAnimation {
                        expanded = true
                    }
                }
                .padding(.top)
            }
            
            if expanded {
                Button("Hide") {
                    withAnimation {
                        expanded = false
                    }
                }
                .padding(.top)
            }
        }
        
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
    
    let post: Post
    let showPin: Bool
    @StateObject var mediaSize: MediaSize
    //@Binding var postToShow: Post?
    //let namespace: Namespace.ID
        
    @State var linkIsPresented: Bool = false
    @State private var showMedia: Bool = false
    @State private var maxY: CGFloat = .zero
    @State private var selfTextLineLimit: Int = 10
    
    //@Namespace private var namespace
    /*init(post: Post, showPin: Bool, mediaSize: MediaSize){
        self.post = post
        self.showPin = showPin
        
        self._mediaSize = StateObject(wrappedValue: mediaSize)
    }*/
    
    var body: some View {

        
        VStack(spacing: 0){
            
            if post.stickied && showPin {
                HStack{
                    Image(systemName: "pin.fill")
                        .foregroundColor(Color.green)
                        .rotationEffect(.degrees(45))
                        .padding(5)
                    Text("PINNED BY MODERATORS")
                        .foregroundColor(Color.gray)
                        .bold()
                        .font(.system(size: 10))
                    Spacer()
                }
            }
            
            VStack{
                VStack{
                    
                    NavigationLink {
                        PostView(post: post, linkIsPresented: $linkIsPresented)
                    } label: {
                       
                        ZStack(alignment: .leading){
                            
                            Rectangle()
                                .foregroundColor(.clear)
                                .contentShape(Rectangle())
                                .frame(idealWidth: .infinity)
                            
                            Text(post.title)
                                
                                .bold()
                                .multilineTextAlignment(.leading)
                                //.matchedGeometryEffect(id: "posttitle\(post.uuid)", in: namespace, properties: .position)
                                .frame(maxHeight: 60)
                        }

                    }
                    .buttonStyle(.plain)
                    .padding([.top, .bottom], 10)

                    if post.postLinkType == .permalink { // self post
                        
                        SelfText(post.selfText)
                            .padding(.bottom)
                        
                    }
                    else if post.postLinkType == .link { // external link
                        LinkAndThumbnailView(thumbnailUrl: post.thumbnailUrl, postUrl: post.url)
                            .onTapGesture {
                                linkIsPresented.toggle()
                            }
                    }
                    else {
                        
                        PostMediaViewer(post: post, cornerRadius: 10, showContextMenu: true)
                            //.contentCornerRadius(radius: 10)
                            //.matchedGeometryEffect(id: "postmedia\(post.uuid)", in: namespace, properties: .position, anchor: .center)
                            .padding(.bottom, 10)
                            .overlay {
                                
                                GeometryReader { geo in
                                    
                                    Color.clear
                                        .onAppear {
                                            if geo.size.height > mediaSize.size.height {
                                                mediaSize.size = geo.size
                                            }
                                        }
                                }
                                
                            }
                            .frame(minWidth: mediaSize.size.width, minHeight: mediaSize.size.height) // Impedisce alla view di tornare piccola quando viene ricaricata durante lo scroll (LazyVStack), cosi da non far saltare la scrollview
                            
                        
                    }
                    
                    
                    
                }
                    
                HStack{
                    Button {
                        
                    } label: {
                     Image("arrowshape.up.fill")
                         .foregroundColor(Color.gray)
                    }
                    
                    Text(post.ups.toKNotation())
                        .frame(width: 35, alignment: .leading)
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                    
                    Button {
                        
                    } label: {
                        Image("arrowshape.up.fill")
                            .rotationEffect(.degrees(180))
                            .foregroundColor(Color.gray)
                            //.padding(.leading, 5)
                    }
                    
                    NavigationLink {
                        PostView(post: post, linkIsPresented: $linkIsPresented)
                    } label: {
                        HStack{
                            Image(systemName: "message.fill")
                            Text("\(post.numComments)")
                                .font(.system(size: 12))
                        }
                    }
                    .padding(.leading)
                    .foregroundColor(Color.gray)
                    
                    Text(post.getTimeSiceCreationFormatted())
                        .foregroundColor(Color.gray)
                        .font(.system(size: 12))
                        .bold()
                        .padding(.leading)
                    
                    if post.over18 {
                        NsfwSymbolView()
                    }
                    
                    if post.locked {
                        Image(systemName: "lock")
                            .foregroundColor(Color.gray)
                    }
                    
                    
                    Spacer()
                    Text(post.subreddit)
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                }
            }
        }
        .fullScreenCover(isPresented: $linkIsPresented) {
            SafariView(url: post.url)
        }
        
    
    
    }
    
}



/*struct LargePostCardView_Previews: PreviewProvider {
    
    
    
    static let media: [String : Any] = [
        "reddit_video": [
            "bitrate_kbps": 1200,
            "dash_url": "https://v.redd.it/o7ckl9gcjvpa1/DASHPlaylist.mpd?a=1682335733%2CY2NhODRjMmI4OTg3YzEyNDdiMjEyZjE4MzE0MDdhOTIzYWJmYjA0YzljNDBkZGVkZmUyMzcyOTUwMThiMWYxYw%3D%3D&amp;v=1&amp;f=sd",
            "duration": 29,
            "fallback_url": "https://v.redd.it/o7ckl9gcjvpa1/DASH_480.mp4?source=fallback",
            "hls_url": "https://v.redd.it/o7ckl9gcjvpa1/HLSPlaylist.m3u8?a=1682335733%2CM2ZjYWFiNWI2NDUxYmY2ZjE0YjNmMDc2Zjc1NjMwMTE3YzIzMzYzMWVlYmE0MjIwYjMzNWQxNGI0YjE1MGE4Yw%3D%3D&amp;v=1&amp;f=sd",
            "is_gif": 0,
            "scrubber_media_url": "https://v.redd.it/o7ckl9gcjvpa1/DASH_96.mp4",
            "width": 384,
            "height": 480
        ]
    ]
    
    static let postData: [String : Any] = [
        "ups": 100000,
        "downs": 2,
        "likes": 0,
        "created": 0.0,
        "created_utc": 0.0,
        "author": "author",
        "hidden": 0,
        "is_self": 0,
        "locked": 1,
        "num_comments": 20,
        "over_18": 1,
        "score": 8,
        "selftext": "Testo di prova",
        "subreddit": "subreddit",
        "subreddit_id": "1234",
        "thumbnail": "image",
        "title": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
        "permalink": "aaaa",
        "url": "https://www.zooplus.it/magazine/wp-content/uploads/2020/05/1-32.jpg",
        "stickied": 1
        //"media": media
    ]
    
    static var previews: some View {
        LargePostCardView(post: Post(id: nil, name: nil, kind: "", data: postData), showPin: true)
            .previewLayout(.sizeThatFits)
    }
}*/
