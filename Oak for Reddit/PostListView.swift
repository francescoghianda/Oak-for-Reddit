//
//  PostListView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 21/03/23.
//

import SwiftUI

struct PostListView: View {
    
    let subreddit: Subreddit
    
    /*init(subreddit: Subreddit) {
        self.subreddit = subreddit
        //UIToolbar.appearance().backgroundColor = UIColor(hexString: subreddit.primaryColor)
    }*/
    
    var body: some View {
            ScrollView{
                LazyVStack{

                    /*ForEach(1..<20) { index in
                        Rectangle()
                            .frame(width: .infinity, height: 100)
                            .foregroundColor(Color.blue)
                    }*/
                    Color(hexString: subreddit.primaryColor)
                        .frame(height: 200)
                    SubredditIcon(subreddit: subreddit, background: .white)
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 200, height: 200)
                        .overlay {
                            Circle().stroke(Color(hexString: subreddit.primaryColor), lineWidth: 4)
                        }
                        .offset(y: -100)
                        .padding(.bottom, -100)
                        
                    Spacer()
                    
                }
            }
            .navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack{
                        SubredditIcon(subreddit: subreddit, background: .white)
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 40, height: 40)
                        Text(subreddit.displayNamePrefixed)
                            .padding(.leading)
                    }
                }
            }
        
    }
}

struct PostListView_Previews: PreviewProvider {
    static var previews: some View {
        PostListView(subreddit: Subreddit.previewSubreddit)
    }
}
