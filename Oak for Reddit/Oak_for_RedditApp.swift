//
//  Oak_for_RedditApp.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 15/03/23.
//

import SwiftUI

@main
struct Oak_for_RedditApp: App {
    //@StateObject var redditApi = RedditApi()
    //@StateObject var oauth: OAuthManager = OAuthManager.shared
    //@UIApplicationDelegateAdaptor var applicationDelegate: ApplicationDelegate
    let persistenceController = PersistenceController.shared
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                //.environmentObject(redditApi)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                //.environmentObject(oauth)
                .onOpenURL{url in
                    
                    /*let urlScheme = url.scheme
                    let redirectUrlScheme = OAuthManager.CALLBACK_URL_SCHEME
                    
                    guard urlScheme?.caseInsensitiveCompare(redirectUrlScheme) == .orderedSame
                    else { return }
                                        
                    oauth.onCallbackUrl(url: url)*/
                }
        }
    }
    
}



/*class ApplicationDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
        
        
    }
    
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
    }
    
}*/
