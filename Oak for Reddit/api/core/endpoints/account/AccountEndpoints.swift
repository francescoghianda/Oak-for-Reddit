//
//  AccountEndpoints.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 26/04/23.
//

import Foundation

extension Endpoint {
    
    static func accountInfo() -> Endpoint {
        
        return Endpoint(method: .get, scopes: [.identity], needsAccount: true, path: "/api/v1/me", parameters: [:])
        
    }
    
}
