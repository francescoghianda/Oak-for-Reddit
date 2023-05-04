//
//  OAuthManager.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 17/03/23.
//

import Foundation
import CoreData
import AuthenticationServices

class OAuthManager: ObservableObject {
    
    public static let shared = OAuthManager()
    
    private static let AUTHORIZE_URL = "https://www.reddit.com/api/v1/authorize.compact" //"https://old.reddit.com/v1/api/authorize"
    private static let TOKEN_REQUEST_URL = "https://www.reddit.com/api/v1/access_token"
    public static let CALLBACK_URL_SCHEME = "oakforreddit"
    public static let CALLBACK_URL = "\(CALLBACK_URL_SCHEME)://oauth"
    
    private let deviceId: String = OAuthManager.getDeviceId()
    
    private let defaultsAuthorizationDataKey = "authorizationData"
    
    private var scopeParameters = ["read", "identity", "vote"]
    private var responseTypeParameter = "code"
    private var tokenDurationParameter = "permanent"
    
    private var authenticationSession: ASWebAuthenticationSession? = nil
    
    private let accountsManager = AccountsManager.shared
    private var authorizationData: AuthorizationData? {
        return AccountsManager.shared.any?.authData
    }
    private var moc: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    
    private static func getDeviceId() -> String {
        let defaults = UserDefaults.standard
        guard let deviceId = defaults.string(forKey: "deviceId")
        else {
            let deviceId = UUID.init().uuidString
            defaults.set(deviceId, forKey: "deviceId")
            return deviceId
        }
        return deviceId
    }
    
    func getValidAccount(needsLogin: Bool = false, onSuccess: @escaping (Account) -> Void, onFail: @escaping () -> Void) {
        
        let account = needsLogin ? accountsManager.logged : accountsManager.any
        
        if let account = account {
            let isValid = Date.now.distance(to: account.authData.expireDate) > 0
            
            if(isValid){
                onSuccess(account)
                return
            }
            
            // The access token is expired
            
            refreshToken(account: account, onSuccess: onSuccess) { error in
                onFail()
            }
        }
        else if needsLogin {
            
            authenticate { error in
                if error == nil {
                    if let account = self.accountsManager.logged {
                        onSuccess(account)
                    }
                }
                else {
                    onFail()
                }
            }
            
        }
        else {
            fetchAuthorizationData(type: .installed_client) { authorizationData in
                let account = self.accountsManager.createGuestAccount(authData: authorizationData)
                onSuccess(account)
            } onFail: { error in
                onFail()
            }
        }
        
    }
    
    func refreshToken(account: Account, onSuccess: @escaping (Account) -> Void, onFail: @escaping (FetchError) -> Void){
        let refreshToken: String? = account.authData.refreshToken
        let requestType: AuthorizationRequestType = refreshToken != nil ? .refresh : .installed_client
        
        
        fetchAuthorizationData(type: requestType, refreshToken: refreshToken) { newAuthData in
            self.moc.performAndWait {
                account.setValue(newAuthData, forKey: "authData")
                //account.authData = newAuthData
                try? self.moc.save()
            }
            onSuccess(account)
            
        } onFail: { error in
            onFail(error)
        }
    }
    
    func authenticate(completionHandler: ((AuthenticationError?) -> Void)? = nil) {
        
        if let session = authenticationSession {
            session.cancel()
        }
        
        let state = UUID.init().uuidString
        let authUrl = buildAuthorizationUrl(state: state)
        authenticationSession = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: OAuthManager.CALLBACK_URL_SCHEME) { [weak self] callbackUrl, error in
            guard let callbackUrl = callbackUrl  else {
                completionHandler?(.authentication_session_error(error))
                return
            }
            
            self?.completeAuthentication(callbackUrl: callbackUrl, state: state) { error in
                if let error = error {
                    completionHandler?(error)
                }
                else {
                    completionHandler?(nil)
                }
            }
            
        }
        let contextProvider = AuthenticationViewController()
        authenticationSession?.presentationContextProvider = contextProvider
        authenticationSession?.prefersEphemeralWebBrowserSession = true
        authenticationSession?.start()
    }
    
    private func completeAuthentication(callbackUrl: URL, state: String, completionHandler: @escaping (AuthenticationError?) -> Void) {
        
        guard let stateParam = callbackUrl.getQueryParameter("state"),
              stateParam == state
        else {
            completionHandler(.invalid_state_parameter)
            return
        }
        
        guard let codeParam = callbackUrl.getQueryParameter("code")
        else {
            completionHandler(.missing_code_parameter)
            return
        }
        
        fetchAuthorizationData(type: .code, codeParameter: codeParam) { authData in
            
            self.moc.performAndWait {
                
                let account = Account(context: self.moc) // TODO retrieve account information
                account.setValuesForKeys([
                    "authData": authData,
                    "guest": false
                ])
                try? self.moc.save()
            }
            
            completionHandler(nil)
            
        } onFail: { error in
            completionHandler(.fetch_authorization_data_error(error))
        }
    }
    
    private func buildAuthorizationUrl(state: String) -> URL {
        let scopes = scopeParameters.joined(separator: ",")
        let urlStr = "\(OAuthManager.AUTHORIZE_URL)?client_id=\(ApiFetcher.API_CLIENT_ID)&response_type=\(responseTypeParameter)&duration=\(tokenDurationParameter)&state=\(state)&redirect_uri=\(OAuthManager.CALLBACK_URL)&scope=\(scopes)"
        return URL(string: urlStr)!
    }
    
    
    private func buildAuthorizationRequest(type: AuthorizationRequestType, codeParameter: String? = nil, refreshToken: String? = nil) -> URLRequest? {
        
        let url = URL(string: OAuthManager.TOKEN_REQUEST_URL)!
        
        var request = URLRequest(url: url)
        request.setValue(ApiFetcher.USER_AGENT, forHTTPHeaderField: "User-Agent")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let authtorizationToken = Data("\(ApiFetcher.API_CLIENT_ID):".utf8).base64EncodedString()
        request.setValue("Basic \(authtorizationToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        
        if(type == .code){
            guard codeParameter != nil
            else{
                print("Error: Missing code parameter")
                return nil;
            }
        }
        else if(type == .refresh){
            guard refreshToken != nil
            else{
                print("Error: Missing refresh token")
                return nil;
            }
        }
        
        let parameters: [String: String] = {
            
            switch type {
            case .code:
                return [
                    "grant_type": "authorization_code",
                    "code": codeParameter!,
                    "redirect_uri": OAuthManager.CALLBACK_URL
                ]
            case .refresh:
                return [
                    "grant_type": "refresh_token",
                    "refresh_token": refreshToken!
                ]
            case .installed_client:
                return [
                    "grant_type": "https://oauth.reddit.com/grants/installed_client",
                    "device_id": self.deviceId,
                ]
            }
            
        }()
                        
        request.httpBody = parameters.percentEncoded()
        
        return request
    }
    
    private func fetchAuthorizationData(type: AuthorizationRequestType, codeParameter: String? = nil, refreshToken: String? = nil, onSuccess: @escaping (AuthorizationData) -> Void, onFail: @escaping (FetchError) -> Void) {
        
        let request = buildAuthorizationRequest(type: type, codeParameter: codeParameter, refreshToken: refreshToken)!
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse
            else {
                onFail(.unexpected(error: error))
                
                //self.failAuthorization(message: "Error: \(error ?? URLError(.badServerResponse))")
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
            
            do {
                
                if let dataDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    
                    let accessToken = dataDictionary["access_token"] as? String
                    let tokenType = dataDictionary["token_type"] as? String
                    let expiresIn = dataDictionary["expires_in"] as? Int
                    let scope = dataDictionary["scope"] as? String
                                        
                    switch type {
                    case .code:
                        let refreshToken = dataDictionary["refresh_token"] as? String
                        let authData = AuthorizationData(moc: self.moc, accessToken: accessToken!, tokenType: tokenType!, expiresIn: Int64(expiresIn!), scope: scope!, refreshToken: refreshToken!, expireDate: Date.now.advanced(by: TimeInterval(expiresIn!)))
                        onSuccess(authData)
                        
                    case .refresh:
                        let newAuthorizationData = AuthorizationData(moc: self.moc, accessToken: accessToken!, tokenType: tokenType!, expiresIn: Int64(expiresIn!), scope: scope!, refreshToken: refreshToken, expireDate: Date.now.advanced(by: TimeInterval(expiresIn!)))
                        onSuccess(newAuthorizationData)
                        
                    case .installed_client:
                        let authData = AuthorizationData(moc: self.moc, accessToken: accessToken!, tokenType: tokenType!, expiresIn: Int64(expiresIn!), scope: scope!, refreshToken: nil, expireDate: Date.now.advanced(by: TimeInterval(expiresIn!)))
                        onSuccess(authData)
                    }
                }
                else {
                    onFail(.parser_error)
                }
                
            }
            catch {
                onFail(.parser_error)
                //print(error)
                return
            }
            
        }

        task.resume()
    }
    
}

enum AuthenticationError: Error {
    case invalid_state_parameter
    case missing_code_parameter
    case fetch_authorization_data_error(_ error: FetchError)
    case authentication_session_error(_ error: Error?)
}

class MissingAuthorizationData: Error{
    
}

enum AuthorizationRequestType{
    case code, refresh, installed_client
}

enum AuthorizationStatus {
    case authorized, unauthorized, pending, failed, refreshing
}

enum LoginStatus {
    case initialized, pending, completed, failed, canceled
}

class AuthenticationViewController: UIViewController, ASWebAuthenticationPresentationContextProviding
{
    var window: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }
        return window
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window ?? ASPresentationAnchor()
    }
}
