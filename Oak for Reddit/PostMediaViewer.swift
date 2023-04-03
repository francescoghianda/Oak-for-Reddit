//
//  PostMediaViewer.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 02/04/23.
//

import SwiftUI

struct GalleryView: View {
    
    let galleryData: GalleryData
    
    let contentCornerRadius: CGFloat
    
    @State var pageIndex: Int = 0
    @State var width: CGFloat = 100
    @State var height: CGFloat = 100
    
    var body: some View {
        
        TabView(selection: $pageIndex) {
            
            ForEach(0..<galleryData.items.count) { index in
                
                PostImageView(url: galleryData.items[index].url)
                    .onImageLoad{ image in
                        width = max(width, image.size.width)
                        height = max(height, image.size.height)
                    }
                    .cornerRadius(contentCornerRadius)
                    .tag(index)
                
            }
            
        }
        .frame(idealWidth: width, idealHeight: height)
        .scaledToFit()
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        
    }
    
}

class PostSize: ObservableObject {
    
    @Published var height: CGFloat = .zero
    var aspectRatio: CGFloat? = nil
    
}

class PostSizeCache {
    
    private static var cache: [URL : PostSize] = [:]
    
    static func getPostSize(url: URL) -> PostSize {
        
        if let size = cache[url] {
            return size
        }
        
        let size = PostSize()
        cache[url] = size
        return size
        
    }
    
}

struct PostImageView: View {
    
    let url: URL
    
    var onImageLoadHandler: ((_ image: UIImage) -> Void)? = nil
    
    //@State var height: CGFloat = .zero
    //@StateObject private var imageSize: PostSize
    
    init(url: URL, onImageLoadHandler: ((_ image: UIImage) -> Void)? = nil) {
        self.url = url
        self.onImageLoadHandler = onImageLoadHandler
        //_imageSize = StateObject(wrappedValue: PostSizeCache.getPostSize(url: url))
    }
    
    func onImageLoad(_ perform: @escaping (_ image: UIImage) -> Void) -> PostImageView {
        return PostImageView(url: url, onImageLoadHandler: perform)
    }
    
    var body: some View {
        
        AsyncUIImage(url: url) { image, error in
            
            if let image = image {
                
                Image(uiImage: image)
                    .resizable()
                    //.scaledToFit()
                    .onAppear {
                        
                        onImageLoadHandler?(image)
                    }
            }
            else if error != nil {
                
                Image("error_icon")
                
            }
            else {
                ProgressView()
            }
            
        }
        /*.onFirstLoad { image in
            let aspectRatio = imageSize.aspectRatio ?? (image.size.height / image.size.width)
            imageSize.aspectRatio = aspectRatio
            
            imageSize.height = 358 * aspectRatio
        }*/
        //.frame(height: imageSize.height)
        
        
    }
    
}

struct PostMediaViewer: View {
    
    let post: Post
    
    var cornerRadius: CGFloat = 0
    
    @State var image: UIImage? = nil
    
    func contentCornerRadius(radius: CGFloat) -> PostMediaViewer {
        PostMediaViewer(post: post, cornerRadius: radius)
    }
    
    var body: some View {
        
        if post.postLinkType == .image {
            
            PostImageView(url: post.url)
                .scaledToFit()
                .cornerRadius(cornerRadius)
            
        }
        
        if post.postLinkType == .gallery, let galleryData = post.galleryData {
            
            GalleryView(galleryData: galleryData, contentCornerRadius: cornerRadius)
            
        }
        
        if post.postLinkType == .video {
            
            switch post.media! {
            case .redditVideo(let data):
                RedditVideoPlayer(url: data.hlsUrl!)
                    .scaledToFit()
                    .cornerRadius(cornerRadius, antialiased: true)
                
            case .embed(let data):
                EmbedVideoPlayer(media: data)
                    .frame(idealWidth: CGFloat(data.width), idealHeight: CGFloat(data.height))
                    .scaledToFit()
                    .cornerRadius(cornerRadius, antialiased: true)
            case .unknown:
                Rectangle()
            }
            
        }
        
    }
}

/*struct PostMediaViewer_Previews: PreviewProvider {
    static var previews: some View {
        PostMediaViewer()
    }
}*/
