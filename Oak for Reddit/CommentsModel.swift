//
//  CommentsModel.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 05/04/23.
//

import Foundation

enum CommentsOrder: String {
    case confidence, top, new, controversial, old, random, qa
}

class CommentsModel: ObservableObject {
        
    private let api = RedditApi.shared
    
    @Published var comments: Listing<Comment> = Listing.empty()
    
    private let endpoint: ApiEndpoint
    
    private let postId: String
    private let subredditName: String?
    
    init(postId: String, subredditName: String? = nil) {
        self.postId = postId
        self.subredditName = subredditName
        let path =  "\((subredditName ?? ""))/comments/\(postId)"
        self.endpoint = ApiEndpoint(scope: "read", path: path, method: "GET", parameters: [:])
    }
    
    private func fetch(parameters: [String : Any]) async throws -> Listing<Comment> {
        
        let endpoint = self.endpoint.withParameters([
            "limit": 30
            //"depth": 4
        ])
        
        let result = try await api.fetchJsonArray(endpoint: endpoint)
        
        let comments: Listing<Comment> = Listing.build(from: result[1])
        
        //printComments(comments)
        
        return comments
    }
    
    func load() async {
        
        do {
            self.comments = try await fetch(parameters: [:])
        }
        catch{
            print("Error loading comments")
        }
        
    }
    
    func printComments(_ comments: Listing<Comment>, level: Int = 0) {
        
        for comment in comments {
            
            let tabs = String(repeating: "\t", count: level)
            print("\(tabs)\(comment.body)")
            printComments(comment.replies, level: level + 1)
            
        }
        
    }
    
}
