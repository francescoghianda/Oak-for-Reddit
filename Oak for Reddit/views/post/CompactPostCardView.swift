//
//  PostCardView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 23/03/23.
//

import SwiftUI

fileprivate struct MediaSheetView: View {
    
    @ObservedObject var userPreferences = UserPreferences.shared
    
    let post: Post
    
    @State var showDots: Bool = false
    @State var image: UIImage? = nil
    
    @State var contentWidth: CGFloat = .zero
    @State var imageSavedToastPresenting: Bool = false
    @State var errorToastPresenting: Bool = false
    
    @StateObject var imageLoader = AsyncImageLoader()
    
    var body: some View{
        
        ZStack {
            
            ZoomableScrollView {
                PostMediaViewer(post: post, currentImage: $image, width: $contentWidth)
            }
            .onZoomChange { zoomScale in
                withAnimation {
                    showDots = zoomScale > 1
                }
            }
            
            
            VStack {
                HStack(alignment: .center){
                    
                    Spacer()
                    
                    if userPreferences.mediaQuality != .original {
                        Menu {
                            
                            Button {
                                saveOriginal()
                            } label: {
                                Label {
                                    Text("Original quality")
                                } icon: {
                                    EnchantedDownloadIcon()
                                }
                            }
                            
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        } primaryAction: {
                            saveImage(image)
                        }
                        .disabled(image == nil)

                    }

                }
                .padding()
                .frame(height: 48)
                .background(.thinMaterial)
                .overlay(alignment: .top) {
                    Capsule()
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 5)
                        .padding(.top, 4)
                }
                
                Spacer()
            }
           
            
        }
        .overlay {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        contentWidth = geo.size.width
                    }
                    .onChange(of: geo.size.width) { newWidth in
                        contentWidth = newWidth
                    }
            }
        }
        .toast(isPresenting: $imageSavedToastPresenting) {
            Text("Image saved")
        }
        .toast(isPresenting: $imageLoader.isLoading, autoClose: false) {
            VStack{
                Text("Download")
                let progress = Int(imageLoader.progress * 100)
                Text("\(progress)%")
            }
        }
        .toast(isPresenting: $errorToastPresenting) {
            Text("An error occured")
        }
        
    }
    
    private func saveImage(_ image: UIImage?) {
        if let image = image {
            ImageSaver()
                .onImageSaved {
                    DispatchQueue.main.async {
                        imageSavedToastPresenting = true
                    }
                }
                .saveImage(image: image)
        }
    }
    
    private func saveOriginal() {
        if let url = post.previews?.preview(resolution: .original).url {
            imageLoader.load(url: url) { image, error in
                guard let image = image else {
                    DispatchQueue.main.async {
                        errorToastPresenting = true
                    }
                    return
                }
                
                saveImage(image)
            }
        }
        else {
            errorToastPresenting = true
        }
        
    }
}

struct PostThumbnailView: View {
    
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
    
    @ObservedObject var post: Post
    let showPin: Bool
    let linkToSubredditIsActive: Bool
    
    @State var photoIsPresented: Bool = false
    
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
                HStack(alignment: .top){
                    
                    NavigationLink {
                        PostView(post: post)
                    } label: {
                        Text(post.title)
                            .bold()
                            .padding(.trailing)
                            .frame(height: 60, alignment: .top)
                    }
                    .buttonStyle(.plain)
                    

                    Spacer()
                    
                    if post.postLinkType == .link {
                        NavigationLink {
                            SafariView(url: post.url!)
                                .navigationBarHidden(true)
                        } label: {
                            PostThumbnailView(mediaSheetIsPresented: $photoIsPresented, post: post, size: 60)
                                .cornerRadius(10)
                        }
                    }
                    else {
                        PostThumbnailView(mediaSheetIsPresented: $photoIsPresented, post: post, size: 60)
                            .cornerRadius(10)
                            .onTapGesture {
                                if post.containsMedia {
                                    photoIsPresented = true
                                }
                            }
                    }
                            
                    
                }
                HStack{
                    
                    Group {
                        Button {
                            post.vote(dir: .upvote)
                        } label: {
                            Image("arrowshape.up.fill")
                                .foregroundColor(post.upvoted ? .blue : .gray)
                        }
                        
                        Text(post.ups.toKNotation())
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Button {
                            post.vote(dir: .downvote)
                        } label: {
                            Image("arrowshape.up.fill")
                                .rotationEffect(.degrees(180))
                                .foregroundColor(post.downvoted ? .red : .gray)
                        }
                    }
                    
                    
                    Group {
                        Image(systemName: "message.fill")
                        
                        Text("\(post.numComments.toKNotation())")
                            .font(.system(size: 12))
                        
                        if post.locked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    .foregroundColor(.gray)
                    
                    if post.over18 {
                        NsfwSymbol()
                    }
                    
                    Spacer()
                    
                    Text(post.getTimeSiceCreationFormatted())
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                        .bold()
                    
                    Text("·")
                        .foregroundColor(.gray)
                    
                    NavigationLink {
                        PostListView(subredditNamePrefixed: "r/\(post.subreddit)")
                    } label: {
                        Text(post.subreddit)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .disabled(!linkToSubredditIsActive)
                }
            }
        }
        
        .sheet(isPresented: $photoIsPresented) {
            MediaSheetView(post: post)
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
