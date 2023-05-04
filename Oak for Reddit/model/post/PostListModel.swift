//
//  PostListModel.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 21/03/23.
//

import Foundation
import SwiftUI


class PostListModel: ObservableObject {
    
    private let api: ApiFetcher = ApiFetcher.shared
    
    let subredditNamePrefixed: String
    
    @Published var posts: Listing<Post> = Listing.empty()
    @Published private(set) var loading: Bool = false
    @Published private(set) var loadingMore: Bool = false
    @Published private(set) var error: FetchError? = nil
    @Published private(set) var loadingMoreError: Error? = nil
    
    init(subredditNamePrefixed: String? = nil){
        
        if let subredditNamePrefixed = subredditNamePrefixed {
            self.subredditNamePrefixed = "/\(subredditNamePrefixed)"
        }
        else {
            self.subredditNamePrefixed = ""
        }
    }
    
    
    func load(order: PostListingOrder) {
        
        if loading || loadingMore {
            return
        }
        
        loading = true
        error = nil
        
        Task {
            
            do {
                let posts: Listing<Post> = try await api.fetchListing(.postListing(order: order, subredditName: subredditNamePrefixed))
                
                Task { @MainActor [weak self] in
                    self?.posts = posts
                    self?.loading = false
                }
            }
            catch let error as FetchError {
                Task { @MainActor [weak self] in
                    self?.error = error
                    self?.loading = false
                }
            }
            
        }
        
    }
    
    func loadMore(order: PostListingOrder) {
        
        if loading || loadingMore {
            return
        }
        
        loadingMore = true
        loadingMoreError = nil
       
        Task {
            
            do {
                let after = posts.after ?? posts.last?.subredditId ?? ""
                
                let newPosts: Listing<Post> = try await api.fetchListing(.postListing(order: order, subredditName: subredditNamePrefixed, after: after, count: posts.count))
                
                Task { @MainActor [weak self] in
                    self?.posts += newPosts
                    self?.loadingMore = false
                }
            }
            catch let error as FetchError {
                Task { @MainActor [weak self] in
                    self?.loadingMoreError = error
                    self?.loadingMore = false
                }
            }
            
        }
       
    }
    
}
