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
    
}

extension ApiEndpoint {
    
    func withParameters(_ parameters: [String : Any]) -> ApiEndpoint {
        return ApiEndpoint(scope: scope, path: path, method: method, parameters: parameters)
    }
    
    func addParameter(key: String, value: Any) -> ApiEndpoint {
        var parameters = self.parameters
        parameters[key] = value
        return self.withParameters(parameters)
    }

    func prefixPath(_ prefix: String) -> ApiEndpoint {
        let newPath = prefix + path
        return ApiEndpoint(scope: scope, path: newPath, method: method, parameters: parameters)
    }
}
