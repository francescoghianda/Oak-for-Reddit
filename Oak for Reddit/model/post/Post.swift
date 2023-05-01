//
//  Post.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 21/03/23.
//

import Foundation
import SwiftUI
import CoreData

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

@objc(Post)
public class Post: Thing, Votable, Created {

    
    var ups: Int = 0
    var downs: Int = 0
    @Published var likes: Bool? = nil {
        didSet {
            super.willChangeValue(forKey: "likes")
            self.objectWillChange.send()
        }
    }
    
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
    
    var created: Date = .now
    var createdUtc: Date = .now
    
    let author: String = ""
    let hidden: Bool = false
    let isSelf: Bool = false
    let locked: Bool = false
    let numComments: Int = 0
    let over18: Bool = false
    let score: Int = 0
    let selfText: String = ""
    let subreddit: String = ""
    let subredditId: String = ""
    let thumbnail: String = ""
    let thumbnailUrl: URL? = nil
    let title: String = ""
    let permalink: String = ""
    let url: URL? = nil
    let edited: TimeInterval? = nil
    let stickied: Bool = false
    let media: Media? = nil
    let isGallery: Bool = false
    let galleryData: GalleryData? = nil
    //let imageSize: ImageSize?
    let previews: PostPreviews? = nil
    let isSpoiler: Bool = false
    let pollData: PollData? = nil
    
    private(set) var tags: [Tag] = []
    
    required init(id: String, name: String, kind: String, data: [String : Any]) {
        
        let moc = PersistenceController.shared.container.viewContext
        guard let entityDesc = NSEntityDescription.entity(forEntityName: "Post", in: moc)
        else {
            fatalError("Thing entity not found!")
        }
        
        super.init(entityDecription: entityDesc, id: id, name: name, kind: kind, data: data)
        
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
        
        if let galleryData = data["gallery_data"] as? [String : Any],
           let metadata = data["media_metadata"] as? [String : Any],
            (data["is_gallery"] as? Int ?? 0) != 0
        {
            
            isGallery = true
            self.galleryData = GalleryData(galleryData: galleryData, metadata: metadata)
            
        }
        else {
            
            /*if (data["is_gallery"] as? Int ?? 0) != 0 {
                print(data)
            }*/
            
            isGallery = false
            galleryData = nil
        }
        
        if let preview = data["preview"] as? [String : Any]
           //let images = preview["images"] as? [[String : Any]],
           //let img = images.first,
           //let source = img["source"] as? [String : Any],
           //let width = source["width"] as? Int,
           //let height = source["height"] as? Int
        {
            self.previews = PostPreviews(previewsData: preview)
            
            //imageSize = ImageSize(width: width, height: height)
        }
        else {
            
            //imageSize = nil
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
                        
        //super.init(id: id, name: name, kind: kind, data: data)
        
    }
    
    
    required init(entityDecription: NSEntityDescription, id: String, name: String, kind: String, data: [String : Any]) {
        fatalError("init(entityDecription:id:name:kind:data:) has not been implemented")
    }
    
    required init(entity: NSEntityDescription, insertInto: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: insertInto)
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
