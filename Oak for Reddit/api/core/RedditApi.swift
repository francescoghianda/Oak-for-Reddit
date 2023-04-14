//
//  RedditAPI.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 15/03/23.
//

import Foundation
import Combine
import SwiftUI


class RedditApi: NSObject{
    typealias Parser<T> = (_ data: Data) throws -> T?
    typealias JSONObject = [String : Any]
    typealias JSONArray = [JSONObject]
    
    public static let shared: RedditApi = RedditApi()
    
    private static let APP_VERSION: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
    private static let APP_ID: String = Bundle.main.bundleIdentifier!
    
    public static let API_CLIENT_ID: String = "qzz2XGAnh0wDeUx3oKWBuA"
    private static let API_BASE_URL: String = "https://oauth.reddit.com"
    public static let USER_AGENT: String = "iOS:\(APP_ID):\(APP_VERSION) (by /u/Francy5615)"
    
    public let oauth: OAuthManager = OAuthManager.shared
    
    private var xRateLimitUsed: Int = 0
    private var xRateLimitRemainig: Int = .max
    private var xRateLimitReset: Int = 0
    
    
    override init(){
        super.init()
    }
    
    private func buildRequest(endpoint: Endpoint) -> URLRequest? {
        
        let urlString: String = {
            if(endpoint.method != .get){
                return "\(RedditApi.API_BASE_URL)\(endpoint.path)"
            }
            let params = endpoint.parameters.map { (param: String, value: Any) in
                "\(param)=\(value)"
            }.joined(separator: "&")
            return "\(RedditApi.API_BASE_URL)\(endpoint.path)?\(params)"
        }()
        
        guard let url = URL(string: urlString)
        else{
            print("Error: Invalid API path: \(urlString)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue(RedditApi.USER_AGENT, forHTTPHeaderField: "User-Agent")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpMethod = endpoint.method.rawValue.uppercased()
        
        if(endpoint.method != .get){
            request.httpBody = endpoint.parameters.percentEncoded()
        }
        
        return request
    }
    
    func fetchListing<T>(_ endpoint: Endpoint) async throws -> Listing<T> {
        return Listing.build(from: try await fetchJsonObject(endpoint))
    }
    
    func fetchJsonObject(_ endpoint: Endpoint) async throws -> JSONObject {
        return try await fetch(endpoint: endpoint, parser: Parsers.jsonParser)
    }
    
    func fetchJsonArray(_ endpoint: Endpoint) async throws -> JSONArray {
        return try await fetch(endpoint: endpoint, parser: Parsers.jsonParser)
    }
    
    func fetchRaw(_ endpoint: Endpoint) async throws -> Data {
        return try await fetch(endpoint: endpoint, parser: Parsers.identity)
    }
    
    func fetch<T>(endpoint: Endpoint, parser: @escaping Parser<T>) async throws -> T {
        
        let result: T = try await withCheckedThrowingContinuation({ continuation in
            fetch(endpoint: endpoint, parser: parser) { result in
                continuation.resume(returning: result)
            } onFail: { failCause in
                continuation.resume(throwing: ApiFetchError(cause: failCause))
            }
        })
        
        return result
    }
    
    
    func fetch<T>(endpoint: Endpoint,
                  parser: @escaping Parser<T>,
                  onSuccess: @escaping (T) -> Void,
                  onFail: ((ApiFetchFailCause) -> Void)? = nil) {
        

        oauth.getValidAccessToken { accessToken in
            
            guard var request = self.buildRequest(endpoint: endpoint)
            else{
                onFail?(.unknown)
                return
            }
            
            print("Making API request to: \(request.url!)")
            
            //print(accessToken)
            
            request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            self.makeRequest(request: request, parser: parser, onSuccess: onSuccess) { failCause in
                switch failCause {
                case .unauthorized:
                    print("Invalid access token.")
                    print("Trying to refresh the access token")
                    
                    self.oauth.refreshToken(onSuccess: { accessToken in
                        request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        self.makeRequest(request: request, parser: parser, onSuccess: onSuccess) { cause in
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
    
    private func makeRequest<T>(request: URLRequest,
                                parser: @escaping Parser<T>,
                                onSuccess: @escaping (T) -> Void,
                                onFail: @escaping (ApiFetchFailCause) -> Void)  {
                
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                print(error?.localizedDescription ?? "")
                onFail(.unknown)
                return
            }
            
            
            if(response.statusCode == 401){
                onFail(.unauthorized)
                return
            }
            
            self.updateRateLimits(response: response)
            
            do {
                if let parsed = try parser(data) {
                    onSuccess(parsed)
                    return
                }
                else {
                    onFail(.bad_response)
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
    
    
    private func updateRateLimits(response: HTTPURLResponse) {
        let xRateLimitUsed: String? = response.value(forHTTPHeaderField: "x-ratelimit-used")
        let xRateLimitRemainig: String? = response.value(forHTTPHeaderField: "x-ratelimit-remaining")
        let xRateLimitReset: String? = response.value(forHTTPHeaderField: "x-ratelimit-reset")
        
        self.xRateLimitUsed = Int(xRateLimitUsed ?? "0")!
        self.xRateLimitRemainig = Int(xRateLimitRemainig ?? "300")!
        self.xRateLimitReset = Int(xRateLimitReset ?? "600")!
        
        //print("xRateLimitUsed: \(self.xRateLimitUsed), xRateLimitRemaining: \(self.xRateLimitRemainig), xRateLimitReset:\(self.xRateLimitReset)")
    }
    
}

class ApiFetchError: Error {
    let cause: ApiFetchFailCause
    let localizedDescription: String
    
    init(cause: ApiFetchFailCause){
        self.cause = cause
        self.localizedDescription = {
            cause.rawValue
        }()
    }
}

enum ApiFetchFailCause: String {
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
