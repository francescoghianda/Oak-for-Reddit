//
//  GalleryView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 28/04/23.
//

import Foundation
import SwiftUI

struct GalleryView: View {
    
    @EnvironmentObject var userPreferences: UserPreferences
    
    let galleryData: GalleryData
    @Binding var width: CGFloat
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
        
        let height = getMaxHeight()
        
        TabView(selection: $pageIndex) {
            
            ForEach(0..<galleryData.items.count) { index in
                
                PostImageView(previews: galleryData.items[index].previews, showContextMenu: showContextMenu)
                    .onImageLoad{ image in
                        onImageChangeHandler?(image)
                    }
                    .scaledToFit()
                    .cornerRadius(contentCornerRadius)
                    .tag(index)
                
            }
            
        }
        .frame(height: height)
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
    
    /*private func getMaxWidth() -> CGFloat {
        var max = 0
        for item in galleryData.items {
            if item.width > max {
                max = item.width
            }
        }
        return CGFloat(max)
    }*/
    
    private func getMaxHeight() -> CGFloat {
        
        var max: CGFloat = .zero
        for item in galleryData.items {
            
            let height = width / item.previews.preview(resolution: .original).aspectRatio
            if height > max {
                max = height
            }
        }
        
        return CGFloat(min(600, max))
    }
    
}
