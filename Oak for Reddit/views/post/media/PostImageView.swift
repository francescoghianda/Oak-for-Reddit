//
//  PostImageView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 28/04/23.
//

import Foundation
import SwiftUI


struct PostImageView: View {
    
    @EnvironmentObject var userPreferences: UserPreferences
    
    let url: URL?
    let previews: PostPreviews?
    var onImageLoadHandler: ((_ image: UIImage) -> Void)? = nil
    var showContextMenu: Bool = false
    
    @State var image: UIImage? = nil
    
    @State var toastPresenting: Bool = false
    @State var downloadToastPresenting: Bool = false
    
    @State var downloader: AsyncImageLoader = AsyncImageLoader()
    @State var downloadProgress: Double = .zero
    
    init(url: URL, showContextMenu: Bool = false) {
        self.url = url
        self.previews = nil
        self.showContextMenu = showContextMenu
    }
    
    init(previews: PostPreviews, showContextMenu: Bool = false) {
        self.previews = previews
        self.url = nil
        self.showContextMenu = showContextMenu
    }
    
    
    func onImageLoad(_ perform: @escaping (_ image: UIImage) -> Void) -> some View {
        var newView = self
        newView.onImageLoadHandler = perform
        return newView
    }
    
    
    var body: some View {
        
        
        let url: URL = {
           
            if let previews = previews {
                return previews.preview(resolution: userPreferences.mediaQuality).url
            }
            
            return self.url!
        }()
        
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
                        .onImageSaved {
                            toastPresenting = true
                        }
                        .saveImage(image: image!)
                } label: {
                    Label("Save image", systemImage: "square.and.arrow.down")
                }
                .disabled(image == nil)
                
                if let _ = previews, userPreferences.mediaQuality != .original {
                    
                    Button {
                        saveOriginal()
                    } label: {
                        Label {
                            VStack{
                                Text("Save image")
                                Text("(Original resolution)")
                                    .font(.caption)
                            }
                        } icon: {
                            EnchantedDownloadIcon()
                        }
                        
                    }
                    .disabled(image == nil)
                    
                }
                
                Button {
                    shareAction(image: image!)
                } label: {
                    Label("Share image", systemImage: "square.and.arrow.up")
                }
                .disabled(image == nil)

                
            }
        }
        .toast(isPresenting: $toastPresenting) {
            Text("Image saved")
        }
        .toast(isPresenting: $downloadToastPresenting, autoClose: false) {
            VStack{
                Text("Downloading...")
                //let progress = Int(downloadProgress * 100)
                ProgressView(value: downloadProgress)
                //Text("\(progress)%")
            }
        }
        .onReceive(downloader.$progress) { progress in
            downloadProgress = progress
        }
        
        
    }
    
    func saveOriginal() {
        if let previews = previews {
            
            downloader = AsyncImageLoader()
            
            downloadToastPresenting = true
            
            downloader.load(url: previews.preview(resolution: .original).url) { image, error, cached in
                if let image = image {
                    ImageSaver()
                        .onImageSaved {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                downloadToastPresenting = false
                                toastPresenting = true
                            }
                        }
                        .saveImage(image: image)
                }
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

struct EnchantedDownloadIcon: View {
    
    
    var body: some View {
        VStack {
            Image(systemName: "sparkles")
                .foregroundColor(.yellow)
                .rotationEffect(.degrees(90))
                .scaleEffect(0.8)
                .offset(x: -1, y: 8)
            Image(systemName: "square.and.arrow.down")
        }
        .padding(.top, -10)
    }
}


struct EnchantedDownloadIcon_Previews: PreviewProvider {
    
    static var previews: some View {
        EnchantedDownloadIcon()
            .previewLayout(.sizeThatFits)
    }
    
}
