//
//  VotableService.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 11/05/23.
//

import Foundation
import SwiftUI


protocol VotableService {
    
    func vote(name: String, direction: VoteDirection) async throws -> Bool
    
}

protocol VotableServiceProvider: Named, Votable {
    
    var votableService: VotableService { get }
    
}

extension VotableServiceProvider {
    
    func vote(direction: VoteDirection, completion: ((_ success: Bool) -> Void)? = nil) {
        
        let direction: VoteDirection = {
            
            guard let likes = likes
            else {
                return direction
            }
            
            if (direction == .upvote && likes) || (direction == .downvote && !likes) {
                return .unvote
            }
            
            return direction
        }()
        
        Task {
            
            do {
                let success = try await votableService.vote(name: name, direction: direction)
                
                if success {
                    
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
                        completion?(true)
                    }
                }
                else {
                    completion?(false)
                }
                
            }
            catch {
                print(error)
                completion?(false)
            }
            
        }
        
    }
    
}
