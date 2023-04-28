//
//  OAuthManager.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 17/03/23.
//

import Foundation
import CoreData

class OAuthManager: ObservableObject {
    
    public static let shared = OAuthManager()
    
    private static let AUTHORIZE_URL = "https://www.reddit.com/api/v1/authorize"
    private static let TOKEN_REQUEST_URL = "https://www.reddit.com/api/v1/access_token"
    public static let CALLBACK_URL_SCHEME = "oakforreddit"
    public static let CALLBACK_URL = "\(CALLBACK_URL_SCHEME)://oauth"
    
    private let deviceId: String
    
    private let defaultsAuthorizationDataKey = "authorizationData"
    
    private let semaphore = DispatchSemaphore(value: 1)
    
    private var scopeParameters = ["read", "identity", "vote"]
    private var stateParameter = ""
    private var responseTypeParameter = "code"
    private var tokenDurationParameter = "permanent"
    
    private var errorMessage = ""
    
    @Published public var authorizationSheetIsPresented = false
    private(set) var authSheetStartTabIndex: Int = 0
    
    
    private var loginStatus: LoginStatus = .initialized {
        didSet {
            if [.completed, .canceled, .failed].contains(loginStatus) {
                Task {
                    onLoginCompletion?(loginStatus)
                }
            }
        }
    }
    
    private var onLoginCompletion: ((LoginStatus) -> Void)? = nil
    
    private let accountsManager = AccountsManager.shared
    
    private var authorizationData: AuthorizationData? {
        
        return AccountsManager.shared.any?.authData
        
    }
    
    private var moc: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    private init(){
        
        deviceId = OAuthManager.getDeviceId()
        
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
            
            refreshToken(account: account, onSuccess: onSuccess)
        }
        else if needsLogin {
            
            startAuthorization { status in
                if status == .completed {
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
            }
        }
        
    }
    
    public func refreshToken(account: Account, onSuccess: @escaping (Account) -> Void){
        let refreshToken: String? = account.authData.refreshToken
        let requestType: AuthorizationRequestType = refreshToken != nil ? .refresh : .installed_client
        
        
        fetchAuthorizationData(type: requestType, refreshToken: refreshToken) { newAuthData in
            self.moc.performAndWait {
                account.setValue(newAuthData, forKey: "authData")
                //account.authData = newAuthData
                try? self.moc.save()
            }
            onSuccess(account)
        }
    }
    
    
    func startAuthorization(startTabIndex: Int = 0, onCompletion: ((LoginStatus) -> Void)? = nil) {
        semaphore.wait()
        if(authorizationSheetIsPresented){
            return
        }
        self.authSheetStartTabIndex = startTabIndex
        self.onLoginCompletion = onCompletion
        updateStateParameter()
        loginStatus = .pending
        
        Task { @MainActor in
            authorizationSheetIsPresented = true
        }
        
        semaphore.signal()
    }
    
    func onAuthorizationSheetDismissed() {
        
        if loginStatus == .pending {
            loginStatus = .canceled
        }
        
    }
    
    private func failAuthorization(message: String){
        print("Authorization failed: \(message)")
        errorMessage = message
        loginStatus = .failed
        authorizationSheetIsPresented = false
    }
    
    private func updateStateParameter(){
        stateParameter = UUID.init().uuidString
    }
    
    private func getQueryStringParameter(url: URL, param: String) -> String? {
        guard let url = URLComponents(string: url.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    
    func buildAuthorizationUrl() -> URL {
        let scopes = scopeParameters.joined(separator: ",")
        let urlStr = "\(OAuthManager.AUTHORIZE_URL)?client_id=\(ApiFetcher.API_CLIENT_ID)&response_type=\(responseTypeParameter)&duration=\(tokenDurationParameter)&state=\(stateParameter)&redirect_uri=\(OAuthManager.CALLBACK_URL)&scope=\(scopes)"
        return URL(string: urlStr)!
    }
    
    
    func onCallbackUrl(url: URL){
        
        guard let stateParam = getQueryStringParameter(url: url, param: "state"),
              stateParam == stateParameter
        else {
            
            failAuthorization(message: "Invalid state parameter")
            return
        }
        
        guard let codeParam = getQueryStringParameter(url: url, param: "code")
        else {
            failAuthorization(message: "Invalid code parameter")
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
            
            self.loginStatus = .completed
            
            DispatchQueue.main.async {
                self.authorizationSheetIsPresented = false
            }
        }

    }
    
    /*func getAuthorizedRequest(url: URL, then: @escaping (URLRequest) -> Void, onFail: @escaping () -> Void) {
        
        getValidAccount { account in
            let token = account.authData.accessToken
            var request = URLRequest(url: url)
            
            request.setValue(ApiFetcher.USER_AGENT, forHTTPHeaderField: "User-Agent")
            request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
            
            then(request)
        } onFail: {
            onFail()
        }
    }*/
    
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
    
    private func fetchAuthorizationData(type: AuthorizationRequestType, codeParameter: String? = nil, refreshToken: String? = nil, onSuccess: @escaping (AuthorizationData) -> Void) {
        
        let request = buildAuthorizationRequest(type: type, codeParameter: codeParameter, refreshToken: refreshToken)!
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                self.failAuthorization(message: "Error: \(error ?? URLError(.badServerResponse))")
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
                
            }
            catch {
                self.failAuthorization(message: "Invalid authorization data")
                print(error)
                return
            }
            
        }

        task.resume()
    }
    
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
