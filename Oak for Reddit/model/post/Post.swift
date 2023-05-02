//
//  Post.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 21/03/23.
//

import Foundation
import SwiftUI

class GalleryData {
    typealias Dictionary = [String : Any]
    
    struct GalleryItem: Identifiable {
        
        let id: String
        let caption: String?
        let url: URL
        let width: Int
        let height: Int
        
        var aspectRatio: CGFloat {
            CGFloat(width) / CGFloat(height)
        }
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
    case image, video, gallery, media, poll, link, permalink, nolink
}

struct ImageSize {
    let width: Int
    let height: Int
    
    var aspectRatio: Double {
        Double(width) / Double(height)
    }
}

struct PollData {
    
    struct Option: Identifiable {
        let id: Int
        let text: String
        var voteCount: Int
    }
    
    let options: [Option]
    let votingEndDate: Date?
    let isPrediction: Bool
    
    init(pollData: [String : Any]) {
        
        let optionsData = pollData["options"] as! [[String : Any]]
                
        options = optionsData.map{ option in
            let id = Int(option["id"] as! String) ?? 0
            let text = option["text"] as! String
            let voteCount = option["vote_count"] as? Int ?? 0
            return Option(id: id, text: text, voteCount: voteCount)
        }
        
        if let votingEndTimestamp = pollData["voting_end_timestamp"] as? TimeInterval {
            votingEndDate = Date(timeIntervalSince1970: votingEndTimestamp)
        }
        else {
            votingEndDate = nil
        }
        
        isPrediction = (pollData["is_prediction"] as? Int ?? 0) != 0
        
    }
}




enum Tag: Equatable {
    case nsfw
    case spoiler
    case oc
    case custom(text: String, color: Color?)
}

class Post: Thing, Votable, Created {

    var ups: Int
    var downs: Int
    @Published var likes: Bool?
    
    var upvoted: Bool {
        guard let likes = likes
        else {
            return false
        }
        return likes
    }
    
    var downvoted: Bool {
        guard let likes = likes
        else {
            return false
        }
        return !likes
    }
    
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
    //let imageSize: ImageSize?
    let previews: PostPreviews?
    let isSpoiler: Bool
    let pollData: PollData?
    
    private(set) var tags: [Tag] = []
    
    required init(id: String, name: String, kind: String, data: [String : Any]) {
        
        ups = data["ups"] as! Int
        downs = data["downs"] as! Int
        likes = Thing.getBool("likes", from: data)
        
        let createdTI = data["created"] as! TimeInterval
        created = Date(timeIntervalSince1970: createdTI)
        
        let createdUtcTI = data["created_utc"] as! TimeInterval
        createdUtc = Date(timeIntervalSince1970: createdUtcTI)

        author = data["author"] as! String
        hidden = (data["hidden"] as? Int ?? 0) != 0
        isSelf = (data["is_self"] as? Int ?? 0) != 0
        locked = (data["locked"] as? Int ?? 0) != 0
        numComments = data["num_comments"] as! Int
        score = data["score"] as! Int
        selfText = data["selftext"] as! String
        subreddit = data["subreddit"] as! String
        subredditId = data["subreddit_id"] as! String
        thumbnail = data["thumbnail"] as! String
        thumbnailUrl = {
            let thumbnail = data["thumbnail"] as! String
            if thumbnail == "default" || thumbnail == "self" || thumbnail == "image" || thumbnail == "nsfw" {
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
        
        if let galleryData = data["gallery_data"] as? [String : Any],
           let metadata = data["media_metadata"] as? [String : Any],
            (data["is_gallery"] as? Int ?? 0) != 0
        {
            
            isGallery = true
            self.galleryData = GalleryData(galleryData: galleryData, metadata: metadata)
            
        }
        else {
            
            isGallery = false
            galleryData = nil
        }
        
        if let preview = data["preview"] as? [String : Any]{
            self.previews = PostPreviews(previewsData: preview)
        }
        else {
            previews = nil
        }
        
        
        over18 = (data["over_18"] as? Int ?? 0) != 0
        
        if over18 {
            tags.append(.nsfw)
        }
        
        isSpoiler = Thing.getBool("spoiler", from: data)
        
        if isSpoiler {
            tags.append(.spoiler)
        }
        
        if let pollData = data["poll_data"] as? [String : Any] {
            self.pollData = PollData(pollData: pollData)
        }
        else {
            pollData = nil
        }
                        
        super.init(id: id, name: name, kind: kind, data: data)
        
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}

extension Post {
    
    func vote(dir: VoteDirection) {
        
        let direction: VoteDirection = {
            
            guard let likes = likes
            else {
                return dir
            }
            
            if (dir == .upvote && likes) || (dir == .downvote && !likes) {
                return .unvote
            }
            
            return dir
        }()
        
        Task {
            
            do {
                let json = try await ApiFetcher.shared.fetchJsonObject(.vote(thingName: name, dir: direction))
                
                if json.isEmpty {
                    
                    let generator = UINotificationFeedbackGenerator()
                                        
                    DispatchQueue.main.async {
                        switch direction {
                        case .upvote:
                            self.likes = true
                            generator.notificationOccurred(.success)
                        case .unvote:
                            self.likes = nil
                        case .downvote:
                            self.likes = false
                            generator.notificationOccurred(.success)
                        }
                    }
                }
                
            }
            catch {
                print(error)
            }
            
        }
        
    }
    
}

extension Post {
    
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
        
        if pollData != nil {
            return .poll
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
