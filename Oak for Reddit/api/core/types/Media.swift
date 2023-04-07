//
//  Media.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 25/03/23.
//

import Foundation

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
        let bitrateKbps: Int
        let dashUrl: URL?
        let hlsUrl: URL?
        let fallbackUrl: URL?
        let scrubberMediaUrl: URL?
        let isGif: Bool
        let width: Int
        let height: Int
    }
    
    static func build(from data: [String : Any]) -> Media {
        
        if let data = data["reddit_video"] as? [String : Any] {
            
            let bitrate = data["bitrate_kbps"] as! Int
            let dashUrl = Thing.getUrl(data: data, key: "dash_url")
            let hlsUrl = Thing.getUrl(data: data, key: "hls_url")
            let fallbackUrl = Thing.getUrl(data: data, key: "fallback_url")
            let scrubberMediaUrl = Thing.getUrl(data: data, key: "scrubber_media_url")
            let isGif = (data["is_gif"] as? Int ?? 0) != 0
            let width = data["width"] as! Int
            let height = data["height"] as! Int
            
            return .redditVideo(RedditVideo(bitrateKbps: bitrate, dashUrl: dashUrl, hlsUrl: hlsUrl, fallbackUrl: fallbackUrl, scrubberMediaUrl: scrubberMediaUrl, isGif: isGif, width: width, height: height))
        }
        else if let data = data["oembed"] as? [String : Any] {

            
            let type = data["type"] as! String
            let title = data["title"] as? String
            let providerName = data["provider_name"] as! String
            let providerUrl = Thing.getUrl(data: data, key: "provider_url")
            let html = Thing.getHtmlEcodedString(data: data, key: "html")!//data["html"] as! String
            let width = data["width"] as? Int ?? 200
            let height = data["height"] as? Int ?? 113
            
            return .embed(Embed(type: type, title: title, providerName: providerName, providerUrl: providerUrl, html: html, width: width, height: height))
            
        }
        else {
            return .unknown
        }

    }
    
}
