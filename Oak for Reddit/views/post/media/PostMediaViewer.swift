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
    var showContextMenu: Bool = false
    
    var onImageChangeHandler: ((_ image: UIImage) -> Void)? = nil
    
    @State var pageIndex: Int = 0
    
    func onImageChange(_ perform: @escaping (_ image: UIImage) -> Void) -> some View {
        var newView = self
        newView.onImageChangeHandler = perform
        return newView
    }
    
    var body: some View {
        
        TabView(selection: $pageIndex) {
            
            ForEach(0..<galleryData.items.count) { index in
                
                PostImageView(url: galleryData.items[index].url, showContextMenu: showContextMenu)
                    .onImageLoad{ image in
                        onImageChangeHandler?(image)
                    }
                    .scaledToFit()
                    .cornerRadius(contentCornerRadius)
                    .tag(index)
                
            }
            
        }
        .frame(idealWidth: getMaxWidth(), idealHeight: getMaxHeight())
        .scaledToFit()
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        
    }
    
    private func getMaxWidth() -> CGFloat {
        var max = 0
        for item in galleryData.items {
            if item.width > max {
                max = item.width
            }
        }
        return CGFloat(max)
    }
    
    private func getMaxHeight() -> CGFloat {
        var max = 0
        for item in galleryData.items {
            if item.height > max {
                max = item.height
            }
        }
        return CGFloat(max)
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
    var showContextMenu: Bool = false
    
    @State var image: UIImage? = nil
    
    
    func onImageLoad(_ perform: @escaping (_ image: UIImage) -> Void) -> some View {
        var newView = self
        newView.onImageLoadHandler = perform
        return newView
    }
    
    
    var body: some View {
        
        AsyncUIImage(url: url) { image, error in
            
            if let image = image {
                
                Image(uiImage: image)
                    .resizable()
                    .onAppear {
                        self.image = image
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
        .contextMenu {
            if showContextMenu {
                
                Button {
                    ImageSaver()
                        .saveImage(image: image!)
                } label: {
                    Label("Save image", systemImage: "square.and.arrow.down")
                }
                .disabled(image == nil)
                
                Button {
                    shareAction(image: image!)
                } label: {
                    Label("Share image", systemImage: "square.and.arrow.up")
                }
                .disabled(image == nil)

                
            }
        }

        
        
    }
    
    func shareAction(image: UIImage) {
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?.rootViewController!
            .present(activityController, animated: true, completion: nil)
        //UIApplication.shared.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)
    }

    
}

struct PostMediaViewer: View {
    
    let post: Post
    var cornerRadius: CGFloat = 0
    var currentImage: Binding<UIImage?>? = nil
    var showContextMenu: Bool = false
    
    func contentCornerRadius(radius: CGFloat) -> PostMediaViewer {
        var newView = self
        newView.cornerRadius = radius
        return newView
    }
    
    
    var body: some View {
        
        if post.postLinkType == .image {
            
            
            PostImageView(url: post.url!, showContextMenu: showContextMenu)
                .onImageLoad{ image in
                    currentImage?.wrappedValue = image
                }
                .scaledToFit()
                .cornerRadius(cornerRadius)

        }
        
        if post.postLinkType == .gallery, let galleryData = post.galleryData {
            
            GalleryView(galleryData: galleryData, contentCornerRadius: cornerRadius, showContextMenu: showContextMenu)
                .onImageChange { image in
                    currentImage?.wrappedValue = image
                }
            
        }
        
        if post.postLinkType == .video {
            
            switch post.media! {
            case .redditVideo(let data):
                RedditVideoPlayer(url: data.hlsUrl!)
                    .scaledToFit()
                    .cornerRadius(cornerRadius)
                
            case .embed(let data):
                EmbedVideoPlayer(media: data)
                    .frame(idealWidth: CGFloat(data.width), idealHeight: CGFloat(data.height))
                    .scaledToFit()
                    .cornerRadius(cornerRadius)
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
