//
//  URLExtensions.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 08/05/23.
//

import Foundation

extension URL {
    
    func getQueryParameter(_ named: String) -> String? {
        guard let components = URLComponents(string: absoluteString) else { return nil }
        return components.queryItems?.first(where: { $0.name == named })?.value
    }
    
}

extension URLError {
    
    func toFetchError() -> FetchError {
        
        switch errorCode {
        case NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet,
            NSURLErrorInternationalRoamingOff, NSURLErrorTimedOut:
            return .no_connection
            
        default:
            return .unexpected(error: self)
        }
        
        
    }
    
}
