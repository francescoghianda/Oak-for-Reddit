//
//  PostMediaViewer.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 02/04/23.
//

import SwiftUI


struct PostMediaViewer: View {
    
    @ObservedObject var userPreferences = UserPreferences.shared
    
    let post: Post
    var cornerRadius: CGFloat = 0
    var currentImage: Binding<UIImage?>? = nil
    var showContextMenu: Bool = false
    @Binding var width: CGFloat
    
    @State var blurred: Bool = true
    
    
    func contentCornerRadius(radius: CGFloat) -> PostMediaViewer {
        var newView = self
        newView.cornerRadius = radius
        return newView
    }
    
    
    var body: some View {
        
        let blurred = ((userPreferences.blurOver18Images && post.over18) || post.isSpoiler) && self.blurred
        let showHideButton = post.isSpoiler || post.over18
        let blurText = post.over18 ? "THIS POST MAY CONTAIN\nSENSITIVE CONTENT" : "THIS POST MAY CONTAIN\nA SPOILER"
        
        if post.postLinkType == .image {
            
            if let previews = post.previews {
                
                let height: CGFloat = {
                    let preview = previews.preview(resolution: userPreferences.mediaQuality)
                    let val = width / CGFloat(preview.aspectRatio)
                    return min(val, 600)
                }()
                
                PostImageView(previews: previews, showContextMenu: showContextMenu)
                    .onImageLoad{ image in
                        currentImage?.wrappedValue = image
                    }
                    .scaledToFit()
                    .blur(blurred, showHideButton: showHideButton, text: blurText)
                    .cornerRadius(cornerRadius)
                    .frame(height: height)
            }
            else {
                PostImageView(url: post.url!, showContextMenu: showContextMenu)
                    .onImageLoad{ image in
                        currentImage?.wrappedValue = image
                    }
                    .scaledToFit()
                    .blur(blurred, showHideButton: showHideButton, text: blurText)
                    .cornerRadius(cornerRadius)
                    .frame(height: width)
            }
            
            
                

        }
        
        if post.postLinkType == .gallery, let galleryData = post.galleryData {
            
            GalleryView(galleryData: galleryData, width: $width, contentCornerRadius: cornerRadius, showContextMenu: showContextMenu)
                .onImageChange { image in
                    currentImage?.wrappedValue = image
                }
                .blur(blurred, showHideButton: showHideButton, text: blurText)
                .cornerRadius(10)
            
        }
        
        if post.postLinkType == .video {
            
            switch post.media! {
            case .redditVideo(let data):
                
                let height: CGFloat = {
                    let val = width / CGFloat(data.aspectRatio)
                    return min(val, 600)
                }()
                
                let playerWidth: CGFloat = height * CGFloat(data.aspectRatio)
                
                RedditVideoPlayer(url: data.hlsUrl!)
                    .frame(width: playerWidth, height: height)
                    .blur(blurred, showHideButton: showHideButton, text: blurText)
                    .cornerRadius(cornerRadius)
                
            case .embed(let data):
                EmbedVideoPlayer(media: data)
                    .frame(idealWidth: CGFloat(data.width), idealHeight: CGFloat(data.height), maxHeight: 600)
                    .scaledToFit()
                    .blur(blurred, showHideButton: showHideButton, text: blurText)
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
