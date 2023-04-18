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
