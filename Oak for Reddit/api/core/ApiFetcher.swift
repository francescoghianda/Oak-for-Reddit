//
//  RedditAPI.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 15/03/23.
//

import Foundation
import Combine
import SwiftUI


class ApiFetcher: NSObject{
    typealias Parser<T> = (_ data: Data) throws -> T?
    typealias JSONObject = [String : Any]
    typealias JSONArray = [JSONObject]
    
    public static let shared: ApiFetcher = ApiFetcher()
    
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
            if(endpoint.method != .get || endpoint.parameters.isEmpty){
                return "\(ApiFetcher.API_BASE_URL)\(endpoint.path)"
            }
            let params = endpoint.parameters.map { (param: String, value: Any) in
                "\(param)=\(value)"
            }.joined(separator: "&")
            return "\(ApiFetcher.API_BASE_URL)\(endpoint.path)?\(params)"
        }()
        
        guard let url = URL(string: urlString)
        else{
            print("Error: Invalid API path: \(urlString)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue(ApiFetcher.USER_AGENT, forHTTPHeaderField: "User-Agent")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpMethod = endpoint.method.rawValue.uppercased()
        
        if(endpoint.method != .get){
            request.httpBody = endpoint.parameters.percentEncoded()
        }
        
        return request
    }
    
    func fetch<T>(_ endpoint: TypedEndpoint<T>) async throws -> T {
        return try await fetch(endpoint: endpoint.endpoint, parser: endpoint.parser)
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
            } onFail: { fetchError in
                continuation.resume(throwing: fetchError)
            }
        })
        
        return result
    }
    
    
    func fetch<T>(endpoint: Endpoint,
                  parser: @escaping Parser<T>,
                  onSuccess: @escaping (T) -> Void,
                  onFail: ((FetchError) -> Void)? = nil) {
        

        oauth.getValidAccount(needsLogin: endpoint.needsAccount) { account in
            
            guard var request = self.buildRequest(endpoint: endpoint)
            else{
                onFail?(.invalid_request)
                return
            }
            
            let accessToken = account.authData.accessToken
            
            print("Making API request to: \(request.url!)")
            
            //print(accessToken)
            
            request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            self.makeRequest(request: request, parser: parser, onSuccess: onSuccess) { fetchError in
                switch fetchError {
                case .unauthorized:
                    print("Invalid access token.")
                    print("Trying to refresh the access token")
                    
                    self.oauth.refreshToken(account: account, onSuccess: { refreshedAccount in
                        let accessToken = refreshedAccount.authData.accessToken
                        request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        self.makeRequest(request: request, parser: parser, onSuccess: onSuccess) { cause in
                            onFail?(cause)
                            //print("Error calling api")
                        }
                    })
                default:
                    onFail?(fetchError)
                    return
                }
            }
        } onFail: {
            onFail?(.login_error)
        }
        
    }
    
    private func makeRequest<T>(request: URLRequest,
                                parser: @escaping Parser<T>,
                                onSuccess: @escaping (T) -> Void,
                                onFail: @escaping (FetchError) -> Void)  {
                
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                print(error?.localizedDescription ?? "")
                /*if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    onFail(.http_error(code: statusCode))
                }*/
                onFail(.unexpected(error: error))
                
                return
            }
                        
            if response.statusCode >= 400 {
                switch response.statusCode {
                case 400:
                    onFail(.bad_request)
                case 401:
                    onFail(.unauthorized)
                case 403:
                    onFail(.forbidden)
                default:
                    onFail(.http_error(code: response.statusCode))
                }
                
                return
            }
            
            self.updateRateLimits(response: response)
            
            do {
                if let parsed = try parser(data) {
                    onSuccess(parsed)
                    return
                }
                else {
                    onFail(.parser_error)
                }
            }
            catch {
                print("Parser error: \(error.localizedDescription)")
                onFail(.parser_error)
                return
            }
        }
        
        task.resume()
        
    }
    
    
    private func updateRateLimits(response: HTTPURLResponse) {
        let xRateLimitUsed: String? = response.value(forHTTPHeaderField: "x-ratelimit-used")
        let xRateLimitRemainig: String? = response.value(forHTTPHeaderField: "x-ratelimit-remaining")
        let xRateLimitReset: String? = response.value(forHTTPHeaderField: "x-ratelimit-reset")
        
        self.xRateLimitUsed = Int(xRateLimitUsed ?? "0") ?? 0
        self.xRateLimitRemainig = Int(xRateLimitRemainig ?? "300") ?? 300
        self.xRateLimitReset = Int(xRateLimitReset ?? "600") ?? 600
        
        //print("xRateLimitUsed: \(self.xRateLimitUsed), xRateLimitRemaining: \(self.xRateLimitRemainig), xRateLimitReset:\(self.xRateLimitReset)")
    }
    
}

enum FetchError: Error {
    
    case unauthorized
    case invalid_request
    case bad_request
    case parser_error
    case login_error
    case forbidden
    case http_error(code: Int)
    case no_connection
    case unexpected(error: Error?)
    
}

/*class ApiFetchError: Error {
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
    
}*/


