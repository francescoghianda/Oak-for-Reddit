//
//  GalleryData.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 03/05/23.
//

import Foundation

class GalleryData {
    
    struct GalleryItem: Identifiable {
        
        let id: String
        let caption: String?
        let previews: PostPreviews
    }
    
    private static let supportedFormats: [String] = ["jpg", "png", "gif"]
    private static let baseURL = "https://i.redd.it/"
    
    let items: [GalleryItem]
    
    init(galleryData: [String : Any], metadata: [String : Any]) {
        
        items = {
            
            let items = galleryData.getDictionaryArray("items") ?? []//galleryData["items"] as! [Dictionary]
            var galleryItems: [GalleryItem] = []
            
            for item in items {
                
                let mediaId: String = item.get("media_id")//item["media_id"] as! String
                let caption: String? = item.get("caption")//item["caption"] as? String
                let mediaMetadata = metadata.getDictionary(mediaId)!//metadata[mediaId] as! [String : Any]
                
                let previews = PostPreviews(imageData: mediaMetadata, with: .gallery)!
                
                galleryItems.append(GalleryItem(id: mediaId, caption: caption, previews: previews))
                
            }
            
            return galleryItems
            
        }()
        
    }
    
}
