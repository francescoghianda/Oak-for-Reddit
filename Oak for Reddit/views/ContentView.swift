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

fileprivate struct Tabs {
    static let posts = "posts"
    static let subreddits = "subreddits"
    static let settings = "settings"
    static let favorites = "favorites"
    
    static func isTab(_ tag: String?) -> Bool {
        guard let tag = tag else {
            return false
        }

        return tag == Tabs.posts || tag == Tabs.subreddits || tag == Tabs.settings || tag == Tabs.favorites
    }
}

struct ContentView: View {

    
    @State var selectedTab: Int = 2
    @State var selected: String? = Tabs.posts
    
    @ObservedObject var oauthManager = OAuthManager.shared
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var sizeClass: UserInterfaceSizeClass = .compact
    
    var body: some View {
        
        
        Group {
            if horizontalSizeClass == .compact {
                
                let selectedTab = Binding<String> {
                    if Tabs.isTab(selected) {
                        return selected!
                    }
                    return Tabs.favorites
                    
                } set: { value in
                    selected = value
                }

                
                TabView(selection: selectedTab){
                    
                    NavigationView{
                        FavoritesSubredditsView(selected: $selected)
                    }
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("Favorites")
                    }
                    .tag(Tabs.favorites)
                    //.tag(0)
                    
                    NavigationView{
                        SearchableView {
                            SubredditListView()
                        }
                    }
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("Subreddits")
                    }
                    .tag(Tabs.subreddits)
                    //.tag(1)
                    
                    NavigationView{
                        PostListView()
                    }
                    .tabItem {
                        Image(systemName: "list.bullet.below.rectangle")
                        Text("Posts")
                    }
                    .tag(Tabs.posts)
                    //.tag(2)
                    
                    NavigationView {
                        SettingsView()
                    }
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(Tabs.settings)
                    //.tag(3)
                }
                
            }
            else {
                
                let selectedTab = Binding<String?> {
                    return selected
                } set: { value in
                    if let value = value {
                        selected = value
                    }
                }
                
                NavigationView {
                    List {
                        
                        NavigationLink/*(tag: Tabs.subreddits, selection: selectedTab)*/ {
                            SearchableView {
                                SubredditListView()
                            }
                        } label: {
                            Label("Subreddits", systemImage: "list.dash")
                        }
                        .isDetailLink(false)
                        
                        
                        NavigationLink/*(tag: Tabs.posts, selection: selectedTab)*/{
                            PostListView()
                        } label: {
                            Label("Posts", systemImage: "list.bullet.below.rectangle")
                        }
                        
                        NavigationLink/*(tag: Tabs.settings, selection: selectedTab)*/ {
                            
                            SettingsView()
                                
                            
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                        
                        
                        Section("Favorites") {
                            FavoritesSubredditsView(sidebar: true, selected: selectedTab)
                        }
                        
                        
                        
                    }
                    .listStyle(SidebarListStyle())
                    .navigationTitle("Menu")
                
                    
                }
                .navigationViewStyle(.columns)
                
                
            }
        }
        
        
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
