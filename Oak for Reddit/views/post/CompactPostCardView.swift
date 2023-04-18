//
//  PostCardView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 23/03/23.
//

import SwiftUI

fileprivate struct MediaSheetView: View {
    
    let post: Post
    
    @State var showDots: Bool = false
    @State var image: UIImage? = nil
    
    var body: some View{
        
        if post.postLinkType == .image || post.postLinkType == .gallery {
            //PhotoViewerView(url: post.url)
            ZStack{
                
                ZoomableScrollView {
                    PostMediaViewer(post: post, currentImage: $image)
                }
                .onZoomChange { zoomScale in
                    withAnimation {
                        showDots = zoomScale > 1
                    }
                }
                
                
                VStack{
                    HStack(alignment: .center){
                        Spacer()
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .font(.title)
                            .opacity(showDots ? 1 : 0)
                        Spacer()
                        
                        if let image = image {
                            
                            Button {
                                ImageSaver()
                                    .saveImage(image: image)

                            } label: {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(.gray)
                            }
                            
                        }

                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    
                    Spacer()
                }
               
                
            }
        }
        else if post.postLinkType == .video, let media = post.media {
            VideoPlayerView(media: media)
        }
        
    }
}

struct PostThumbnailView: View {
    
    //@Environment(\.namespace) var namespace
    @EnvironmentObject var mediaViewerModel: MediaViewerModel
    @EnvironmentObject var namespaceWrapper: NamespaceWrapper
    
    @Binding var mediaSheetIsPresented: Bool
    
    let post: Post
    let size: CGFloat
    
    var body: some View {
        
        if  post.thumbnail == "image"   ||
            post.thumbnail == "self"    ||
            post.thumbnail == "default"
        {
            Image("no_thumbnail")
                .resizable()
                .frame(width: size, height: size)
        }
        else if let thumbnailUrl = post.thumbnailUrl {
            AsyncImage(url: thumbnailUrl) { image in
                
                image
                    .resizable()
                
            } placeholder: {
                Image("no_thumbnail")
                    .resizable()
                    .frame(width: size, height: size)
            }
            //.matchedGeometryEffect(id: post.uuid, in: namespaceWrapper.namespace, properties: .position)
            .scaledToFill()
            .frame(width: size, height: size)
            .overlay(alignment: .bottomLeading) {
                
                if post.postLinkType == .image || post.postLinkType == .video || post.postLinkType == .link || post.postLinkType == .gallery {
                    //post.postLinkType == .image ? "photo.circle" : "video.circle"
                    let icon: String = {
                        switch post.postLinkType {
                        case .image:
                            return "photo.circle"
                        case .video:
                            return "video.circle"
                        case .gallery:
                            return "photo.stack"
                        case .link:
                            return "safari"
                        default:
                            return ""
                        }
                    }()
                    
                    ZStack{
                        Color.black
                            .opacity(0.5)
                        
                        Image(systemName: icon)
                            .foregroundColor(Color.white)
                            .opacity(0.5)
                    }
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                }
                
            }
            
        }
        else {
            Image("no_thumbnail")
                .resizable()
                .frame(width: size, height: size)
        }
        
    }
}

struct CompactPostCardView: View {
    
    @EnvironmentObject var mediaViewerModel: MediaViewerModel

    
    let post: Post
    let showPin: Bool
    let linkToSubredditIsActive: Bool
    
    @State var photoIsPresented: Bool = false
    @State var linkIsPresented: Bool = false
    
    
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
                HStack{
                    
                    NavigationLink {
                        //PostView(post: post, linkIsPresented: $linkIsPresented)
                    } label: {
                        Text(post.title)
                            .bold()
                            .padding(.trailing)
                            .frame(width: .infinity, height: 60)
                    }
                    .buttonStyle(.plain)
                    

                    Spacer()
                    
                    
                    PostThumbnailView(mediaSheetIsPresented: $photoIsPresented, post: post, size: 60)
                        .cornerRadius(10)
                        .onTapGesture {
                            if post.postLinkType == .image || post.postLinkType == .gallery || post.postLinkType == .video {
                                
                                /*withAnimation(.spring()) {
                                    mediaViewerModel.post = post
                                }*/
                                photoIsPresented = true
                            }
                            else if post.postLinkType == .link {
                                linkIsPresented = true
                            }
                        }
                        //.clipShape(RoundedRectangle(cornerRadius: 10))
                            
                    
                    
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
                    
                    NavigationLink {
                        PostListView(subredditNamePrefixed: "r/\(post.subreddit)")
                    } label: {
                        Text(post.subreddit)
                            .font(.system(size: 14))
                            .foregroundColor(Color.gray)
                    }
                    .disabled(!linkToSubredditIsActive)
                }
            }
        }
        .sheet(isPresented: $photoIsPresented) {
            
            MediaSheetView(post: post)
            
        }
        .fullScreenCover(isPresented: $linkIsPresented) {
            SafariView(url: post.url!)
        }
    
    
    }
    
}

extension Int {
    
    func toKNotation() -> String {
        if(self < 1000){
            return "\(self)"
        }
        
        let div = log10(Float(self))
        
        let letter: String = {
            
            if (div >= 12) {
                return "T"
            }
            if (div >= 9) {
                return "B"
            }
            if (div >= 6) {
                return "M"
            }
            return "K"
        }()
        
        let exp = div - div.truncatingRemainder(dividingBy: 3)
        let num = self / Int(pow(10.0, exp))
        return "\(num)\(letter)"
    }
}

/*struct CompactPostCardView_Previews: PreviewProvider {
    
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
        "url": "aaaa",
        "stickied": 1
    ]
        
    
    static var previews: some View {
        CompactPostCardView(post: Post(id: nil, name: nil, kind: "", data: postData), showPin: true)
            .previewLayout(.sizeThatFits)
    }
}*/
