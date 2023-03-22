//
//  PostApi.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 21/03/23.
//

import Foundation

class PostApi: ObservableObject {
    
    private let redditApi: RedditApi
    
    
    
    
    init(redditApi: RedditApi){
        self.redditApi = redditApi
    }
    
}
