//
//  RedditAPI.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 15/03/23.
//

import Foundation
import Combine
import SwiftUI

class RedditApi: NSObject, ObservableObject{
    
    public static let shared: RedditApi = RedditApi()
    
    private static let APP_VERSION: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
    private static let APP_ID: String = Bundle.main.bundleIdentifier!
    
    public static let API_CLIENT_ID: String = "qzz2XGAnh0wDeUx3oKWBuA"
    private static let API_BASE_URL: String = "https://oauth.reddit.com"
    public static let USER_AGENT: String = "iOS:\(APP_ID):\(APP_VERSION) (by /u/Francy5615)"
    
    public let oauth: OAuthManager = OAuthManager.shared
    
    private override init(){
        super.init()
    }
    
    private func buildRequest(endpoint: ApiEndpoint) -> URLRequest? {
        
        
        let urlString: String = {
            if(endpoint.method != "GET"){
                return "\(RedditApi.API_BASE_URL)\(endpoint.path)"
            }
            let params = endpoint.parameters.map { (param: String, value: Any) in
                "\(param)=\(value)"
            }.joined(separator: "&")
            return "\(RedditApi.API_BASE_URL)\(endpoint.path)?\(params)"
        }()
        
        guard let url = URL(string: urlString)
        else{
            print("Error: Invalid API path")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue(RedditApi.USER_AGENT, forHTTPHeaderField: "User-Agent")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpMethod = endpoint.method
        
        if(endpoint.method != "GET"){
            request.httpBody = endpoint.parameters.percentEncoded()
        }
        
        return request
    }
    
    func callApi(endpoint: ApiEndpoint, onSuccess: @escaping ([String : Any]) -> Void, onFail: ((ApiFetchFailCause) -> Void)? = nil) {
        

        oauth.getValidAccessToken { accessToken in
            
            guard var request = self.buildRequest(endpoint: endpoint)
            else{
                return
            }
            
            
            request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            print("Making API request to: \(request.url!)")
            
            self.makeApiRequest(request: request, onSuccess: onSuccess) { failCause in
                switch failCause {
                case .unauthorized:
                    print("Invalid access token.")
                    print("Trying to refresh the access token")
                    
                    self.oauth.refreshToken(onSuccess: { accessToken in
                        request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        self.makeApiRequest(request: request, onSuccess: onSuccess) { cause in
                            onFail?(cause)
                            print("Error calling api")
                        }
                    })
                    
                case .bad_response:
                    onFail?(failCause)
                    return
                case .unknown:
                    onFail?(failCause)
                    print("Unknown error")
                    return
                }
            }
        }
        
    }
    
    private func makeApiRequest(request: URLRequest, onSuccess: @escaping ([String : Any]) -> Void, onFail: @escaping (ApiFetchFailCause) -> Void)  {
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                print(error)
                onFail(.unknown)
                return
            }
            
            
            if(response.statusCode == 401){
                onFail(.unauthorized)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    onSuccess(json)
                    return
                }
            }
            catch {
                print("Failed to load: \(error.localizedDescription)")
                onFail(.bad_response)
                return
            }
        }
        
        task.resume()
    }
    
}

enum ApiFetchFailCause{
    case unauthorized, bad_response, unknown
}

class UnauthorizedError: Error{
    
}

extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
