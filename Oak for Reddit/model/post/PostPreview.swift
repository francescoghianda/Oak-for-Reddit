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
    
    private var res: [PostPreviewResolution : PostPreview]
    
    init?(previewsData: [String : Any]) {
    
        guard let images = previewsData["images"] as? [[String : Any]],
              let source = images[0]["source"] as? [String : Any],
              let original = PostPreview(source)
        else {
            return nil
        }
        
        let resolutions = images[0]["resolutions"] as? [[String : Any]]
        
        res = [:]
        res[.original] = original
        PostPreviews.addResolutions(resolutions, to: &res)
    }
    
    func preview(resolution: PostPreviewResolution) -> PostPreview {
        
        if let preview = res[resolution] {
            return preview
        }
        else {
            let range = resolution.rawValue..<PostPreviewResolution.original.rawValue
            let cases = PostPreviewResolution.allCases
            
            for i in range {
                if let preview = res[cases[i]] {
                    return preview
                }
            }
            
        }
        
        return res[.original]!
    }
    
    private static func addResolutions(_ resolutions: [[String : Any]]?, to res: inout [PostPreviewResolution : PostPreview]) {
        
        guard let resolutions = resolutions else {
            return
        }
        
        if resolutions.count >= 4 {
            
            res[.low] = PostPreview(resolutions[1])
            
            let midIndex = Int(ceil(Double(resolutions.count) / 2.0))
            res[.medium] = PostPreview(resolutions[midIndex])
            
            res[.good] = PostPreview(resolutions.last!)
        }
        else {
            
            for index in 0..<3 {
                
                let resCase = PostPreviewResolution.init(rawValue: index)!
                
                if let resolution = resolutions[safe: index] {
                    res[resCase] = PostPreview(resolution)
                }
                
            }
        }
    }
    
}
