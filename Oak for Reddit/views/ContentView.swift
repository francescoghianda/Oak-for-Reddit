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
    
    //@EnvironmentObject var redditApi: RedditApi
    //@EnvironmentObject var oauth: OAuthManager
    
    @State var showMedia: Bool = false
    @Namespace var namespace
    
    @StateObject var mediaViewerModel = MediaViewerModel()
    
    @State var selectedTab: Int = 2
    
    var body: some View {
        
        //let subreddits = SubrettitList(redditApi: redditApi)
        
        ZStack {
            
            TabView(selection: $selectedTab){
                FavoritesSubredditsView()
                        .tabItem {
                            Image(systemName: "star.fill")
                            Text("Favorites")
                        }
                        .tag(0)
                SubredditListView()
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
                Text("Account")
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Account")
                        }
                        .tag(3)
            }
            .environmentObject(NamespaceWrapper(namespace))
            .environmentObject(mediaViewerModel)
            //.namespace(namespace)
            
            
            if let post = mediaViewerModel.post {
                
                ZStack {
                    
                    Color.black
                        .ignoresSafeArea()
                    
                    VStack{
                        
                        /*RoundedRectangle(cornerRadius: 10)
                            .matchedGeometryEffect(id: post.uuid, in: namespace, properties: .position)
                            .foregroundColor(.gray)
                            .frame(width: 300, height: 180)
                            .overlay {
                                
                            }*/
                        
                        
                        AsyncUIImage(url: post.url!) { image, error in
                            
                            if let image = image {
                                
                                Image(uiImage: image)
                                    .resizable()
                                
                            }
                            else if error != nil {
                                Text("Error")
                            }
                            else {
                                ProgressView()
                            }
                            
                        }
                        .matchedGeometryEffect(id: post.uuid, in: namespace, properties: .position)
                        .scaledToFit()
                        
                            
                        
                        Button {
                            withAnimation(.spring()) {
                                //mediaViewerModel.mediaIsPresented.toggle()
                                mediaViewerModel.post = nil
                            }
                            
                        } label: {
                            Text("Close viewer")
                        }
                        .padding()

                    }
                    
                }
                .zIndex(1)
                
                
                
            }
            
        }
        //.environmentObject(mediaDataModel)
        
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
