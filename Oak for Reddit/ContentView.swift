//
//  ContentView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 15/03/23.
//

import SwiftUI

struct ContentView: View {
    
    //@EnvironmentObject var redditApi: RedditApi
    //@EnvironmentObject var oauth: OAuthManager
    
    
    
    var body: some View {
        
        //let subreddits = SubrettitList(redditApi: redditApi)
        
        TabView{
            Text("Favourites")
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("Favourites")
                    }
            SubredditsView()
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("Subreddits")
                    }
            Text("Account")
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Account")
                    }
        }
        
        /*VStack{
            
            
            Button("Authorize") {
                redditApi.oauth.startAuthorization()
            }
            .sheet(isPresented: $oauth.authorizationSheetIsPresented) {
                AuthorizationSheet(url: oauth.buildAuthorizationUrl())
            }
        }*/
        
        
        /*switch oauth.authorizationStatus {
        case .authorized, .refreshing:
            Button("Call API test"){
                subreddits.fetchSubreddits()
            }
        default:
            Button("Authorize") {
                redditApi.oauth.startAuthorization()
            }
            .sheet(isPresented: $oauth.authorizationSheetIsPresented) {
                AuthorizationSheet(url: oauth.buildAuthorizationUrl())
            }
        }*/
        
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
