//
//  PostListModel.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 21/03/23.
//

import Foundation
import SwiftUI

class PostListModel: ObservableObject {
    

    private let service: PostService
    let subredditNamePrefixed: String
    
    @Published var posts: Listing<Post> = Listing.empty()
    @Published private(set) var loading: Bool = false
    @Published private(set) var loadingMore: Bool = false
    @Published private(set) var error: FetchError? = nil
    @Published private(set) var loadingMoreError: Error? = nil
    
    init(service: PostService = NetworkPostService(), subredditNamePrefixed: String? = nil){
        
        self.service = service
        
        if let subredditNamePrefixed = subredditNamePrefixed {
            self.subredditNamePrefixed = "/\(subredditNamePrefixed)"
        }
        else {
            self.subredditNamePrefixed = ""
        }
    }
    
    
    func load(order: PostListingOrder, completion: ((Listing<Post>?) -> Void)? = nil) {
        
        if loading || loadingMore {
            return
        }
        
        loading = true
        error = nil
        
        Task {
            
            do {
                let posts: Listing<Post> = try await service.fetch(order: order, subredditName: subredditNamePrefixed)
                
                Task { @MainActor [weak self] in
                    self?.posts = posts
                    self?.loading = false
                    completion?(posts)
                }
            }
            catch let error as FetchError {
                Task { @MainActor [weak self] in
                    self?.error = error
                    self?.loading = false
                    completion?(nil)
                }
            }
            
        }
        
    }
    
    func loadMore(order: PostListingOrder, completion: ((Listing<Post>?) -> Void)? = nil) {
        
        if loading || loadingMore {
            return
        }
        
        loadingMore = true
        loadingMoreError = nil
       
        Task {
            
            do {
                let after = posts.after ?? posts.last?.subredditId ?? ""
                
                let newPosts: Listing<Post> = try await service.fetchMore(order: order, subredditName: subredditNamePrefixed, after: after, count: posts.count)
                
                Task { @MainActor [weak self] in
                    self?.posts += newPosts
                    self?.loadingMore = false
                    completion?(newPosts)
                }
            }
            catch let error as FetchError {
                Task { @MainActor [weak self] in
                    self?.loadingMoreError = error
                    self?.loadingMore = false
                    completion?(nil)
                }
            }
            
        }
       
    }
    
}
