//
//  Media.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 25/03/23.
//

import Foundation
import SwiftUI

enum Media {
    
    case redditVideo(_ data: RedditVideo), embed(_ data: Embed), unknown
    
    struct Embed {
        let type: String
        let title: String?
        let providerName: String
        let providerUrl: URL?
        let html: String
        let width: Int
        let height: Int
    }
    
    struct RedditVideo {
        let bitrateKbps: Int?
        let dashUrl: URL?
        let hlsUrl: URL?
        let fallbackUrl: URL?
        let scrubberMediaUrl: URL?
        let isGif: Bool
        let width: Int
        let height: Int
        
        var aspectRatio: CGFloat {
            CGFloat(width) / CGFloat(height)
        }
    }
    
    static func build(from data: [String : Any]) -> Media {
        
        if let data = data["reddit_video"] as? [String : Any] {
            
            let bitrate = data["bitrate_kbps"] as? Int
            let dashUrl = data.getUrl("dash_url")
            let hlsUrl = data.getUrl("hls_url")
            let fallbackUrl = data.getUrl("fallback_url")
            let scrubberMediaUrl = data.getUrl("scrubber_media_url")
            let isGif: Bool = data.getBool("is_gif")
            let width: Int = data.get("width")
            let height: Int = data.get("height")
            
            return .redditVideo(RedditVideo(bitrateKbps: bitrate, dashUrl: dashUrl, hlsUrl: hlsUrl, fallbackUrl: fallbackUrl, scrubberMediaUrl: scrubberMediaUrl, isGif: isGif, width: width, height: height))
        }
        else if let data = data["oembed"] as? [String : Any] {

            
            let type = data["type"] as! String
            let title = data["title"] as? String
            let providerName = data["provider_name"] as! String
            let providerUrl = data.getUrl("provider_url")
            let html = data.getHtmlEcodedString("html")!
            let width = data.get("width", defaultValue: Int(200))
            let height = data.get("height", defaultValue: Int(113))
            
            return .embed(Embed(type: type, title: title, providerName: providerName, providerUrl: providerUrl, html: html, width: width, height: height))
            
        }
        else {
            return .unknown
        }

    }
    
}
