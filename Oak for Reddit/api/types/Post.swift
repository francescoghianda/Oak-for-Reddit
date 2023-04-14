//
//  Post.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 21/03/23.
//

import Foundation

class GalleryData {
    typealias Dictionary = [String : Any]
    
    struct GalleryItem: Identifiable {
        
        let id: String
        let caption: String?
        let url: URL
        let width: Int
        let height: Int
    }
    
    private static let supportedFormats: [String] = ["jpg", "png", "gif"]
    private static let baseURL = "https://i.redd.it/"
    
    let items: [GalleryItem]
    
    init(galleryData: Dictionary, metadata: Dictionary) {
        
        items = {
            
            let items = galleryData["items"] as! [Dictionary]
            var galleryItems: [GalleryItem] = []
            
            for item in items {
                
                let mediaId = item["media_id"] as! String
                let caption = item["caption"] as? String
                let mediaMetadata = metadata[mediaId] as! Dictionary
                let source = mediaMetadata["s"] as! Dictionary
                let width = source["x"] as! Int
                let height = source["y"] as! Int
                let format = String((mediaMetadata["m"] as! String).split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true)[1])
                
                if GalleryData.supportedFormats.contains(format) {
                    let url = URL(string: "\(GalleryData.baseURL)\(mediaId).\(format)")!
                    galleryItems.append(GalleryItem(id: mediaId, caption: caption, url: url, width: width, height: height))
                }
                
            }
            
            return galleryItems
            
        }()
        
    }
    
}

enum PostLinkType{
    case image, video, gallery, media, link, permalink, nolink
}

class Post: Thing, Votable, Created, ObservableObject {

    var ups: Int
    var downs: Int
    var likes: Bool?
    
    var created: Date
    var createdUtc: Date
    
    let author: String
    let hidden: Bool
    let isSelf: Bool
    let locked: Bool
    let numComments: Int
    let over18: Bool
    let score: Int
    let selfText: String
    let subreddit: String
    let subredditId: String
    let thumbnail: String
    let thumbnailUrl: URL?
    let title: String
    let permalink: String
    let url: URL?
    let edited: TimeInterval?
    let stickied: Bool
    let media: Media?
    let isGallery: Bool
    let galleryData: GalleryData?
    
    required init(id: String?, name: String?, kind: String, data: [String : Any]) {
        
        ups = data["ups"] as! Int
        downs = data["downs"] as! Int
        likes = (data["likes"] as? Int ?? 0) != 0
        
        let createdTI = data["created"] as! TimeInterval
        created = Date(timeIntervalSince1970: createdTI)
        
        let createdUtcTI = data["created_utc"] as! TimeInterval
        createdUtc = Date(timeIntervalSince1970: createdUtcTI)

        author = data["author"] as! String
        hidden = (data["hidden"] as? Int ?? 0) != 0
        isSelf = (data["is_self"] as? Int ?? 0) != 0
        locked = (data["locked"] as? Int ?? 0) != 0
        numComments = data["num_comments"] as! Int
        over18 = (data["over_18"] as? Int ?? 0) != 0
        score = data["score"] as! Int
        selfText = data["selftext"] as! String
        subreddit = data["subreddit"] as! String
        subredditId = data["subreddit_id"] as! String
        thumbnail = data["thumbnail"] as! String
        thumbnailUrl = {
            let thumbnail = data["thumbnail"] as! String
            if thumbnail == "defaults" || thumbnail == "self" || thumbnail == "image"{
                return nil
            }
            return Thing.getUrl(data: data, key: "thumbnail")
        }()
        
        title = Thing.getHtmlEcodedString(data: data, key: "title")!
        
        permalink = data["permalink"] as! String
        url = Thing.getUrl(data: data, key: "url") //data["url"] as! String
        edited = nil
        stickied = (data["stickied"] as? Int ?? 0) != 0
        
        media = Thing.extractMedia(data: data, key: "media")//data["media"] as? [String : Any]
        
        if (data["is_gallery"] as? Int ?? 0) != 0 {
            
            isGallery = true
            galleryData = GalleryData(galleryData: data["gallery_data"] as! [String : Any], metadata: data["media_metadata"] as! [String : Any])
            
        }
        else {
            isGallery = false
            galleryData = nil
        }
        
        let postId = data["id"] as! String      // Thing of Listing dosen't have id and name, but their can be found inside the data of the Thing
        let postName = data["name"] as! String
                        
        super.init(id: postId, name: postName, kind: kind, data: data)
        
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}

extension Post {
    
    /*var timeSiceCreation: TimeInterval {
        Date.now.timeIntervalSince(created)
    }
    
    
    public func formatCreationTime(maxDays: Int = 3, dateFormatter: DateFormatter? = nil) -> String {
        
        let seconds = self.timeSiceCreation
        let mins = Int(seconds / 60)
        let hours = Int(mins / 60)
        let days = Int(hours / 24)
        
        if (seconds < 60){
            return "now"//"\(seconds)s"
        }
        
        if (mins < 60) {
            return "\(mins)m"
        }
        
        if (hours < 24) {
            return "\(hours)h"
        }

        if (days <= maxDays) {
            return "\(days)g"
        }
        
        var formatter = dateFormatter
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.dateFormat = "dd/MM/yy"
        }
        
        return formatter!.string(from: self.created)
    }*/
    
    static let imageFileFormats: [String] = ["jpg", "jpeg", "png", "gif", "gifv", "bmp", "bmpf", "tif", "tiff", "ico", "cur", "xbm"]
    
    var containsMedia: Bool {
        switch postLinkType {
            
        case .image, .video, .gallery, .media:
            return true
 
        default:
            return false
        }
    }
    
    var postLinkType: PostLinkType {
        
        guard let url = url
        else {
            return .nolink
        }
        
        if Post.imageFileFormats.contains(url.pathExtension.lowercased()) {
            return .image
        }
        
        if isGallery {
            return .gallery
        }
        
        if let media = media {
            
            switch media {
            case .redditVideo:
                return .video
            case .embed(let data):
                if data.type == "video" {
                    return .video
                }
                return .media
            case .unknown:
                return .media
            }

        }
        
        if "\(url.path)/" == permalink {
            return .permalink
        }
        
        return .link
    }
}
