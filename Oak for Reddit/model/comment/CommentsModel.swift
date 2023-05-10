//
//  CommentsModel.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 05/04/23.
//

import Foundation
import SwiftUI

@objc public enum CommentsOrder: Int, CaseIterable, Identifiable {
    case confidence, top, new, controversial, old, random, qa
    
    public var id: Int {
        return self.rawValue
    }
    
    public var string: String {
        switch self {
        case .confidence:
            return "best"
        case .top:
            return "top"
        case .new:
            return "new"
        case .controversial:
            return "controversial"
        case .old:
            return "old"
        case .random:
            return "random"
        case .qa:
            return "qa"
        }
    }
}

extension CommentsOrder: ViewRappresentable {
    
    var text: String {
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
    
    var icon: Image {
        switch self {
        case .confidence:
            return Image(systemName: "line.horizontal.star.fill.line.horizontal")
        case .top:
            return Image(systemName: "sparkle.magnifyingglass")
        case .new:
            return Image(systemName: "clock")
        case .controversial:
            return Image(systemName: "bolt.fill")
        case .old:
            return Image(systemName: "hourglass.tophalf.filled")
        case .random:
            return Image(systemName: "dice")
        case .qa:
            return Image(systemName: "person.3.fill")
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
        
    //private let api = ApiFetcher.shared
    private let service: CommentService
    
    @Published var comments: Listing<Comment> = Listing.empty()
    @Published private(set) var loading: Bool = false
    @Published private(set) var error: Error? = nil
        
    private let postId: String
    private let subredditName: String?
    
    init(service: CommentService = NetworkCommentService(), postId: String, subredditName: String? = nil) {
        self.service = service
        self.postId = postId
        self.subredditName = subredditName
    }
    
    
    func load(sort: CommentsOrder) {
        
        if loading {
            return
        }
        
        loading = true
        
        Task {
            
            do {
                let comments = try await service.fetch(order: sort, postId: postId, subredditName: subredditName ?? "")
                
                Task { @MainActor [weak self] in
                    self?.comments = comments
                    self?.loading = false
                }
            }
            catch{
                Task { @MainActor [weak self] in
                    self?.error = error
                }
            }
            
        }
        
    }
    
    
    func loadMoreReplies(listing: Listing<Comment>, count: Int, sort: CommentsOrder, linkId: String, parentId: String) async throws -> Listing<Comment> {
        
        guard let more = listing.more,
              more.count > 0
        else {
            return listing
        }
        
        let splitted = more.children.split(at: count)
        let toLoad = splitted.left
        //let remaining = splitted.right
        
        //let endpoint = Endpoint.moreChildren(order: sort, linkId: linkId, children: toLoad)
        
        let result = try await service.fetchChildren(order: sort, linkId: linkId, childrenIds: toLoad)//try await ApiFetcher.shared.fetch(endpoint: endpoint, parser: Parsers.moreCommentsParser)
        
        let newComments = result.comments
        let newMores = result.mores
        
        let newReplies = listing.children + buildCommentsTree(from: newComments, mores: newMores, parentId: parentId)
        
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
    
    private func buildCommentsTree(from comments: [Comment], mores: [More], parentId: String) -> [Comment] {
        
        let root = comments.filter { comment in
            comment.parentId == parentId
        }
        
        for comment in root {
            
            let children = buildCommentsTree(from: comments, mores: mores, parentId: comment.name)
            let more = mores.first { more in
                more.parentId == comment.name
            }
            
            comment.replies = Listing(before: nil, after: nil, children: children, more: more)
            
        }
        
        return root
    }
    
}
