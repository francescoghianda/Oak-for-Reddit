//
//  AuthorizationSheet.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 15/03/23.
//

import SwiftUI

struct AuthorizationSheet: View {
    
    //@EnvironmentObject var redditApi: RedditApi
    var url: URL
    
    var body: some View {
        VStack{
            HStack(){
                Button("Cancel"){
                    
                }
                Spacer()
            }.padding()
            WebView(url: url)
        }
    }
    
    
}

struct AuthorizationSheet_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationSheet(url: URL(string: "https://google.com")!)
    }
}
