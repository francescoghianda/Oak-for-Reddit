//
//  ContentView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 15/03/23.
//

import SwiftUI

class NamespaceWrapper: ObservableObject {
    
    var namespace: Namespace.ID

    init(_ namespace: Namespace.ID) {
        self.namespace = namespace
    }
    
}

struct ContentView: View {

    
    @State var selectedTab: Int = 2
    @ObservedObject var oauthManager = OAuthManager.shared
    
    @FetchRequest(entity: UserPreferences.entity(), sortDescriptors: [])
    private var userPreferences: FetchedResults<UserPreferences>
    
    var body: some View {
                
        TabView(selection: $selectedTab){
            FavoritesSubredditsView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Favorites")
                }
                .tag(0)
            
            SearchableView {
                SubredditListView()
            }
            .tabItem {
                Image(systemName: "list.dash")
                Text("Subreddits")
            }
            .tag(1)
            
            NavigationView{
                PostListView()
            }
            .tabItem {
                Image(systemName: "list.bullet.below.rectangle")
                Text("Posts")
            }
            .tag(2)
            
            SettingsView()
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(3)
        }
        .sheet(isPresented: $oauthManager.authorizationSheetIsPresented) {
            // onDismiss
        } content: {
            AuthorizationSheet()
        }
        .environmentObject(userPreferences.first!)

        
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}


struct NamespaceEnvironmentKey: EnvironmentKey {
    static var defaultValue: Namespace.ID = Namespace().wrappedValue
}

extension EnvironmentValues {
    var namespace: Namespace.ID {
        get { self[NamespaceEnvironmentKey.self] }
        set { self[NamespaceEnvironmentKey.self] = newValue }
    }
}

extension View {
    func namespace(_ value: Namespace.ID) -> some View {
        environment(\.namespace, value)
    }
}
