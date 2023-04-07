//
//  Endpoint.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 05/04/23.
//

import Foundation

struct Endpoint<T: Thing> {
    
    enum EndpointMethod: String, RawRepresentable {
        case get = "GET", post = "POST"
    }
    
    let scope: String
    let path: String
    let method: EndpointMethod
    
    func getThing(pathParams: CVarArg? = nil, parameters: [String : Any] = [:]) async throws -> T {
        let api = RedditApi.shared
        
        let path = pathParams != nil ? String.localizedStringWithFormat(self.path, pathParams!) : self.path
        
        let result = try await api.callApi(endpoint: ApiEndpoint(scope: scope, path: path, method: method.rawValue, parameters: parameters))
        return Thing.build(from: result)
    }
    
    func getListing(pathParams: [Any]? = nil, parameters: [String : Any] = [:]) async throws -> Listing<T> {
        let api = RedditApi.shared
        
        let path = pathParams != nil ? String.localizedStringWithFormat(self.path, pathParams!) : self.path
        
        let result = try await api.callApi(endpoint: ApiEndpoint(scope: scope, path: path, method: method.rawValue, parameters: parameters))
        return Listing.build(from: result)
    }
    
}
