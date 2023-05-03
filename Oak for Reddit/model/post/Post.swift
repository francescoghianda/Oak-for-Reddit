//
//  Post.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 21/03/23.
//

import Foundation
import SwiftUI


enum PostLinkType{
    case image, video, gallery, media, poll, link, permalink, nolink
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
    let previews: PostPreviews?
    let isSpoiler: Bool
    let pollData: PollData?
    
    private(set) var tags: [Tag] = []
    
    required init(id: String, name: String, kind: String, data: [String : Any]) {
        
        ups = data.get("ups")
        downs = data.get("downs")
        likes = data.getBool("likes")
        
        created = data.getDate("created")
        createdUtc = data.getDate("created_utc")
        
        author = data.get("author")
        hidden = data.getBool("hidden")
        isSelf = data.getBool("is_self")
        locked = data.getBool("locked")
        numComments = data.get("num_comments")
        score = data.get("score")
        selfText = data.get("selftext")
        subreddit = data.get("subreddit")
        subredditId = data.get("subreddit_id")
        
        let thumbnail: String = data.get("thumbnail")
        self.thumbnail = thumbnail
        thumbnailUrl = {
            if thumbnail == "default" || thumbnail == "self" || thumbnail == "image" || thumbnail == "nsfw" {
                return nil
            }
            return data.getUrl("thumbnail")
        }()
        
        title = data.getHtmlEcodedString("title")!
        
        permalink = data.get("permalink")
        url = data.getUrl("url")
        edited = nil
        stickied = data.getBool("stickied")
        
        media = data.getThingMedia("media")
        
        if let galleryData = data.getDictionary("gallery_data"),
           let metadata = data.getDictionary("media_metadata"),
           let isGallery = data.getBool("is_gallery"), isGallery
        {
            
            self.isGallery = true
            self.galleryData = GalleryData(galleryData: galleryData, metadata: metadata)
            
        }
        else {
            
            isGallery = false
            galleryData = nil
        }
        
        if let preview = data.getDictionary("preview"){
            self.previews = PostPreviews.singleImage(previewsData: preview)
        }
        else {
            previews = nil
        }
        
        
        over18 = data.getBool("over_18")
        
        if over18 {
            tags.append(.nsfw)
        }
        
        isSpoiler = data.getBool("spoiler")
        
        if isSpoiler {
            tags.append(.spoiler)
        }
        
        if let pollData = data.getDictionary("poll_data") {
            self.pollData = PollData(pollData: pollData)
        }
        else {
            pollData = nil
        }
                        
        super.init(id: id, name: name, kind: kind, data: data)
        
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
