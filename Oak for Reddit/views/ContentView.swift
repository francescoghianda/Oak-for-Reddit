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
    
    @Environment(\.colorScheme) var colorScheme
    
    @FetchRequest(entity: UserPreferences.entity(), sortDescriptors: [])
    private var userPreferences: FetchedResults<UserPreferences>
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var sizeClass: UserInterfaceSizeClass = .compact
    
    var body: some View {
        
        if sizeClass == .compact {
            
            TabView(selection: $selectedTab){
                
                NavigationView{
                    FavoritesSubredditsView()
                }
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Favorites")
                }
                .tag(0)
                
                NavigationView{
                    SearchableView {
                        SubredditListView()
                    }
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
                
                NavigationView {
                    SettingsView()
                }
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
            }
            .onAppear{
                if let sizeClass = horizontalSizeClass {
                    self.sizeClass = sizeClass
                }
            }
            .sheet(isPresented: $oauthManager.authorizationSheetIsPresented) {
                // onDismiss
            } content: {
                AuthorizationSheet()
            }
            .environmentObject(userPreferences.first!)
            
        }
        else {
            
            NavigationView {
                List {
                    
                    let selected = Binding<Int?> {
                        Optional(selectedTab)
                    } set: {
                        selectedTab = $0 ?? 2
                    }
                    
                    
                    NavigationLink(tag: 1, selection: selected) {
                        Tab {
                            SearchableView {
                                SubredditListView()
                            }
                        }
                    } label: {
                        Label("Subreddits", systemImage: "list.dash")
                    }
                    
                    
                    NavigationLink(tag: 2, selection: selected){
                        Tab {
                            PostListView()
                        }
                    } label: {
                        Label("Posts", systemImage: "list.bullet.below.rectangle")
                    }
                    
                    NavigationLink(tag: 3, selection: selected) {
                        
                        SettingsView()
                        
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                    
                    
                    
                    
                    Section("Favorites") {
                        FavoritesSubredditsView()
                            
                    }
                    
                }
                .listStyle(SidebarListStyle())
                .navigationTitle("Menu")
            
                
            
                
            }
            .navigationViewStyle(.columns)
            .onAppear{
                if let sizeClass = horizontalSizeClass {
                    self.sizeClass = sizeClass
                }
            }
            //SidebarTabView()
            .sheet(isPresented: $oauthManager.authorizationSheetIsPresented) {
                // onDismiss
            } content: {
                AuthorizationSheet()
            }
            .environmentObject(userPreferences.first!)
            
            
        }
        
                
        

        
        
        
    }
}

struct Tab<Content: View>: View, Equatable {
    
    static func == (lhs: Tab<Content>, rhs: Tab<Content>) -> Bool {
        true
    }
    
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        content()
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
