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
    
    init?(_ data: [String : Any]?, with keys: PreviewsKeys) {
        
        guard let data = data,
              let width = data[keys["width"]] as? Int,
              let height = data[keys["height"]] as? Int,
              let urlStr = data[keys["url"]] as? String,
              let url = URL(string: String(htmlEncodedString: urlStr) ?? urlStr)
        else {
            return nil
        }
        
        self.size = CGSize(width: width, height: height)
        self.url = url
    }
    
}

struct PreviewsKeys {
    
    private let keys: [String : String]
    
    private init(_ keys: [String : String]) {
        self.keys = keys
    }
    
    static let singleImage = PreviewsKeys([
        "source": "source",
        "resolutions": "resolutions",
        "width": "width",
        "height": "height",
        "url": "url"
    ])
    
    static let gallery = PreviewsKeys([
        "source": "s",
        "resolutions": "p",
        "width": "x",
        "height": "y",
        "url": "u"
    ])
    
    subscript(_ key: String) -> String {
        keys[key]!
    }
    
}

struct PostPreviews {
    
    private var res: [PostPreviewResolution : PostPreview]
    
    init?(imageData: [String : Any], with keys: PreviewsKeys) {
    
        guard let source = imageData.getDictionary(keys["source"]),//["source"] as? [String : Any],
              let original = PostPreview(source, with: keys)
        else {
            return nil
        }
        
        let resolutions = imageData.getDictionaryArray(keys["resolutions"])//["resolutions"] as? [[String : Any]]
        
        res = [:]
        res[.original] = original
        PostPreviews.addResolutions(resolutions, with: keys, to: &res)
    }
    
    static func singleImage(previewsData: [String : Any]) -> PostPreviews? {
        guard let images = previewsData.getDictionaryArray("images"),
              let image = images[safe: 0]
        else {
            return nil
        }
        
        return PostPreviews(imageData: image, with: .singleImage)
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
    
    private static func addResolutions(_ resolutions: [[String : Any]]?, with keys: PreviewsKeys, to res: inout [PostPreviewResolution : PostPreview]) {
        
        guard let resolutions = resolutions else {
            return
        }
        
        if resolutions.count >= 4 {
            
            res[.low] = PostPreview(resolutions[1], with: keys)
            
            let midIndex = Int(ceil(Double(resolutions.count) / 2.0))
            res[.medium] = PostPreview(resolutions[midIndex], with: keys)
            
            res[.good] = PostPreview(resolutions.last!, with: keys)
        }
        else {
            
            for index in 0..<3 {
                
                let resCase = PostPreviewResolution.init(rawValue: index)!
                
                if let resolution = resolutions[safe: index] {
                    res[resCase] = PostPreview(resolution, with: keys)
                }
                
            }
        }
    }
    
}
