//
//  ApiEndpoint.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 17/03/23.
//

import Foundation

struct ApiEndpoint {
    
    let scope: String
    let path: String
    let method: String
    let parameters: [String : Any]
    
    func withParameters(_ parameters: [String : Any]) -> ApiEndpoint {
        return ApiEndpoint(scope: scope, path: path, method: method, parameters: parameters)
    }
    
}
