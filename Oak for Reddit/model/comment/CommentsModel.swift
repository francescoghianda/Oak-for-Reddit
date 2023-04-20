//
//  CommentsModel.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 05/04/23.
//

import Foundation
import SwiftUI

enum CommentsOrder: String, CaseIterable, Identifiable {
    case confidence, top, new, controversial, old, random, qa
    
    var id: String {
        return UUID().uuidString
    }
    
    var viewString: String {
        switch self {
        case .confidence:
            return "Best"
        case .top:
            return "Top"
        case .new:
            return "New"
        case .controversial:
            return "Controversial"
        case .old:
            return "Old"
        case .random:
            return "Random"
        case .qa:
            return "Interview"
        }
    }
}

extension CommentsOrder {
    
    
    var systemImage: String {
        switch self {
        case .confidence:
            return "line.horizontal.star.fill.line.horizontal"
        case .top:
            return "sparkle.magnifyingglass"
        case .new:
            return "clock"
        case .controversial:
            return "bolt.fill"
        case .old:
            return "hourglass.tophalf.filled"
        case .random:
            return "dice"
        case .qa:
            return "person.3.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .confidence:
            return .purple
        case .top:
            return .orange
        case .new:
            return .blue
        case .controversial:
            return .yellow
        case .old:
            return .red
        case .random:
            return .green
        case .qa:
            return .white
        }
    }
    
}

class CommentsModel: ObservableObject {
        
    private let api = RedditApi.shared
    
    @Published var comments: Listing<Comment> = Listing.empty()
        
    private let postId: String
    private let subredditName: String?
    
    init(postId: String, subredditName: String? = nil) {
        self.postId = postId
        self.subredditName = subredditName
    }
    
    private func fetch(sort: CommentsOrder) async throws -> Listing<Comment> {
        
        let result = try await api.fetchJsonArray(.commentListing(order: sort, postId: postId, subredditName: subredditName ?? ""))
        
        let comments: Listing<Comment> = Listing.build(from: result[1])
                
        return comments
    }
    
    func load(sort: CommentsOrder) async {
        
        do {
            self.comments = try await fetch(sort: sort)
        }
        catch{
            print("Error loading comments")
        }
        
    }
    
    
    static func loadMoreReplies(listing: Listing<Comment>, count: Int, sort: CommentsOrder, linkId: String, parentId: String) async -> Listing<Comment> {
        
        guard let more = listing.more,
              more.count > 0
        else {
            return listing
        }
        
        let splitted = more.children.split(at: count)
        let toLoad = splitted.left
        //let remaining = splitted.right
        
        let endpoint = Endpoint.moreChildren(order: sort, linkId: linkId, children: toLoad)
        
        do {
            let result = try await RedditApi.shared.fetch(endpoint: endpoint, parser: Parsers.moreCommentsParser)
            
            let newComments = result.comments
            let newMores = result.mores
            
            let newReplies = listing.children + CommentsModel.buildCommentsTree(from: newComments, mores: newMores, parentId: parentId)
            
            let newIds = newComments.map { comment in
                comment.thingId
            }
            
            let remaining = listing.more?.filter({ id in
                !newIds.contains(id)
            })
            
            let remainingMore: More? = {
                guard let remaining = remaining
                else {
                    return nil
                }
                return More(children: remaining,
                            name: listing.more?.name,
                            id: listing.more?.id,
                            count: remaining.count,
                            depth: listing.more?.depth,
                            parentId: listing.more?.parentId)
            }()
            
            return Listing(before: listing.before, after: listing.after, children: newReplies, more: remainingMore)
            
        }
        catch {
            print(error.localizedDescription)
            return listing
        }
    }
    
    private static func buildCommentsTree(from comments: [Comment], mores: [More], parentId: String) -> [Comment] {
        
        let root = comments.filter { comment in
            comment.parentId == parentId
        }
        
        for comment in root {
            
            let children = buildCommentsTree(from: comments, mores: mores, parentId: comment.name!)
            let more = mores.first { more in
                more.parentId == comment.name
            }
            
            comment.replies = Listing(before: nil, after: nil, children: children, more: more)
            
        }
        
        return root
    }
    
}
