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
    //private var authorizationData: AuthorizationData? = nil
    
    private var scopeParameters = ["read", "identity"]
    private var stateParameter = ""
    private var responseTypeParameter = "code"
    private var tokenDurationParameter = "permanent"
    
    private var errorMessage = ""
    
    @Published public var authorizationSheetIsPresented = false
    @Published public var authorizationStatus: AuthorizationStatus = .unauthorized
    
    //private(set) var accessToken: String? = nil
    
    private let accountsManager = AccountsManager.shared
    
    private var authorizationData: AuthorizationData? {
        
        return AccountsManager.shared.account?.authData
        
    }
    
    private var moc: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    private init(){
        
        deviceId = OAuthManager.getDeviceId()
        
        /*authorizationData = retrieveAuthorizationData()
        
        if(authorizationData != nil){
            setAuthorizationData(authorizationData: authorizationData!)
        }*/
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
    
    func getValidAccount(onSuccess: @escaping (Account) -> Void) {
        
        let account = accountsManager.account
        
        if let account = account {
            let isValid = Date.now.distance(to: account.authData.expireDate) > 0
            
            if(isValid){
                onSuccess(account)
                return
            }
            
            // The access token is expired
            
            refreshToken(account: account, onSuccess: onSuccess)
            return
        }
        
        fetchAuthorizationData(type: .installed_client) { authorizationData in
            let account = self.accountsManager.createGuestAccount(authData: authorizationData)
            onSuccess(account)
        }
    }
    
    public func refreshToken(account: Account, onSuccess: @escaping (Account) -> Void){
        let refreshToken: String? = account.authData.refreshToken
        let requestType: AuthorizationRequestType = refreshToken != nil ? .refresh : .installed_client
        
        self.authorizationStatus = .refreshing
        
        fetchAuthorizationData(type: requestType, refreshToken: refreshToken) { newAuthData in
            account.authData = newAuthData
            try? self.moc.save()
            onSuccess(account)
        }
    }
    
    
    func startAuthorization() {
        semaphore.wait()
        if(authorizationSheetIsPresented){
            return
        }
        updateStateParameter()
        authorizationSheetIsPresented = true
        authorizationStatus = .pending
        semaphore.signal()
    }
    
    private func failAuthorization(message: String){
        print("Authorization failed: \(message)")
        errorMessage = message
        authorizationStatus = .failed
        authorizationSheetIsPresented = false
    }
    
    private func updateStateParameter(){
        stateParameter = UUID.init().uuidString
    }
    
    private func getQueryStringParameter(url: URL, param: String) -> String? {
        guard let url = URLComponents(string: url.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    /*private func storeAuthorizationData(authData: AuthorizationData){
        let encoder = JSONEncoder()
        
        do{
            let encoded = try encoder.encode(authData)
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: defaultsAuthorizationDataKey)
        }
        catch{
            print("Error storing authorization data: \(error)")
        }
        
    }
    
    private func retrieveAuthorizationData() -> AuthorizationData? {
        
        let defaults = UserDefaults.standard
        if let authData = defaults.object(forKey: defaultsAuthorizationDataKey) as? Data {
            let decoder = JSONDecoder()
            return try? decoder.decode(AuthorizationData.self, from: authData)
        }
        return nil
    }*/
    
    func buildAuthorizationUrl() -> URL {
        let scopes = scopeParameters.joined(separator: ",")
        let urlStr = "\(OAuthManager.AUTHORIZE_URL)?client_id=\(RedditApi.API_CLIENT_ID)&response_type=\(responseTypeParameter)&duration=\(tokenDurationParameter)&state=\(stateParameter)&redirect_uri=\(OAuthManager.CALLBACK_URL)&scope=\(scopes)"
        return URL(string: urlStr)!
    }
    
    /*private func setAndStoreAuthorizationData(authorizationData: AuthorizationData){
        setAuthorizationData(authorizationData: authorizationData)
        self.storeAuthorizationData(authData: authorizationData)
    }
    
    private func setAuthorizationData(authorizationData: AuthorizationData){
        self.authorizationData = authorizationData
        self.authorizationStatus = .authorized
        self.accessToken = authorizationData.accessToken
    }*/
    
    func onCallbackUrl(url: URL){
        semaphore.wait()
        authorizationSheetIsPresented = false
        
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
            let account = Account(context: self.moc) // TODO retrieve account information
            account.authData = authData
            account.name = "Test"
            account.guest = false
            try? self.moc.save()
        }

    }
    
    
    
    private func buildAuthorizationRequest(type: AuthorizationRequestType, codeParameter: String? = nil, refreshToken: String? = nil) -> URLRequest? {
        let url = URL(string: OAuthManager.TOKEN_REQUEST_URL)!
        
        var request = URLRequest(url: url)
        request.setValue(RedditApi.USER_AGENT, forHTTPHeaderField: "User-Agent")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let authtorizationToken = Data("\(RedditApi.API_CLIENT_ID):".utf8).base64EncodedString()
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
                    "code": refreshToken!,
                    "redirect_uri": OAuthManager.CALLBACK_URL
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

/*struct AuthorizationData: Codable {
    
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let scope: String
    let refreshToken: String?
    
    let expireDate: Date
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope = "scope"
        case refreshToken = "refresh_token"
        case expireDate = "expire_date"
    }
}*/
