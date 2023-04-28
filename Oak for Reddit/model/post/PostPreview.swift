//
//  PostImage.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 28/04/23.
//

import Foundation
import SwiftUI

@objc public enum PostPreviewResolution: Int {
    
    case low, medium, good, original
}

extension PostPreviewResolution: Identifiable {
    
    public var id: Int {
        self.rawValue
    }
}

extension PostPreviewResolution: CaseIterable {
    
}

extension PostPreviewResolution {
    var text: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .good:
            return "Good"
        case .original:
            return "Original"
        }
    }
}

struct PostPreview {
    
    let url: URL
    let size: CGSize
    var aspectRatio: CGFloat {
        size.width / size.height
    }
    
    init?(_ data: [String : Any]?) {
        
        guard let data = data,
              let width = data["width"] as? Int,
              let height = data["height"] as? Int,
              let urlStr = data["url"] as? String,
              let url = URL(string: String(htmlEncodedString: urlStr) ?? urlStr)
        else {
            return nil
        }
        
        self.size = CGSize(width: width, height: height)
        self.url = url
    }
    
}

struct PostPreviews {
    
    private(set) var res: [PostPreviewResolution : PostPreview]
    
    init?(previewsData: [String : Any]) {
        
        guard let images = previewsData["images"] as? [[String : Any]],
              let resolutions = images[0]["resolutions"] as? [[String : Any]],
              let source = images[0]["source"] as? [String : Any],
              let original = PostPreview(source),
              let good = PostPreview(resolutions[safe: 5]),
              let medium = PostPreview(resolutions[safe: 3]),
              let low = PostPreview(resolutions[safe: 1])
        else {
            return nil
        }
        
        res = [:]
        res[.original] = original
        res[.good] = good
        res[.medium] = medium
        res[.low] = low
    }
    
    func preview(resolution: PostPreviewResolution) -> PostPreview {
        return res[resolution]!
    }
    
}
