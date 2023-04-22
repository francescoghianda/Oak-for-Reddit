//
//  PostMediaViewer.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 02/04/23.
//

import SwiftUI

struct GalleryView: View {
    
    @EnvironmentObject var userPreferences: UserPreferences
    
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
        .overlay(alignment: .top) {
            
            if let caption = galleryData.items[pageIndex].caption {
                
                HStack{
                    Text(caption)
                        .font(.caption)
                        .padding(5)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
                .padding()
                .id(pageIndex)
                
            }
            
            
        }
        .transition(.opacity)
        .animation(.easeInOut, value: pageIndex)
        
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
    
    @EnvironmentObject var userPreferences: UserPreferences
    
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


struct BlurModifier: ViewModifier {
    
    @State var blurred: Bool
    let showHideButton: Bool
    
    @Namespace private var namespace
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if blurred {
                    ZStack {
                        Rectangle()
                            .background(.ultraThinMaterial)
                        VStack {
                            Button {
                                withAnimation {
                                    blurred = false
                                }
                            } label: {
                                Image(systemName: "eye.circle.fill")
                                    .resizable()
                                    .matchedGeometryEffect(id: "eyeimage", in: namespace)
                                    .frame(width: 50, height: 50)
                                    .scaledToFit()
                            }
                            Text("THIS POST MAY CONTAIN\nSENSITIVE CONTENT")
                                .multilineTextAlignment(.center)
                                .font(.caption2.weight(.bold))
                        }
                        .foregroundColor(.gray)
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                if showHideButton && !blurred {
                    Button {
                        withAnimation {
                            blurred = true
                        }
                    } label: {
                        Image(systemName: "eye.slash.circle.fill")
                            .resizable()
                            .background(.ultraThinMaterial, in: Circle())
                            .matchedGeometryEffect(id: "eyeimage", in: namespace)
                            .frame(width: 30, height: 30)
                            .scaledToFit()
                            
                    }
                    .foregroundColor(.gray)
                    .padding()
                }
            }
    }
    
}

extension View {
    
    func blur(_ blurred: Bool, showHideButton: Bool) -> some View {
        self
            .modifier(BlurModifier(blurred: blurred, showHideButton: showHideButton))
    }
}

struct PostMediaViewer: View {
    
    @EnvironmentObject var userPreferences: UserPreferences
    
    let post: Post
    var cornerRadius: CGFloat = 0
    var currentImage: Binding<UIImage?>? = nil
    var showContextMenu: Bool = false
    var width: CGFloat
    var height: CGFloat
    
    @State var blurred: Bool = true
    
    
    func contentCornerRadius(radius: CGFloat) -> PostMediaViewer {
        var newView = self
        newView.cornerRadius = radius
        return newView
    }
    
    
    var body: some View {
        
        let blurred = userPreferences.blurOver18Images && post.over18 && self.blurred
        
        if post.postLinkType == .image {
            
            
            PostImageView(url: post.url!, showContextMenu: showContextMenu)
                .onImageLoad{ image in
                    currentImage?.wrappedValue = image
                }
                .scaledToFit()
                .blur(blurred, showHideButton: post.over18)
                .cornerRadius(cornerRadius)
                .frame(width: width, height: height)
                

        }
        
        if post.postLinkType == .gallery, let galleryData = post.galleryData {
            
            GalleryView(galleryData: galleryData, contentCornerRadius: cornerRadius, showContextMenu: showContextMenu)
                .onImageChange { image in
                    currentImage?.wrappedValue = image
                }
                .blur(blurred, showHideButton: post.over18)
                .cornerRadius(10)
            
        }
        
        if post.postLinkType == .video {
            
            switch post.media! {
            case .redditVideo(let data):
                RedditVideoPlayer(url: data.hlsUrl!)
                    .scaledToFit()
                    .blur(blurred, showHideButton: post.over18)
                    .cornerRadius(cornerRadius)
                    .frame(width: width, height: height)
                
            case .embed(let data):
                EmbedVideoPlayer(media: data)
                    .frame(idealWidth: CGFloat(data.width), idealHeight: CGFloat(data.height))
                    .scaledToFit()
                    .blur(blurred, showHideButton: post.over18)
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
