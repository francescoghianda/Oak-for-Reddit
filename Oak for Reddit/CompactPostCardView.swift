//
//  PostCardView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 23/03/23.
//

import SwiftUI

struct PostThumbnailView: View {
    
    @Binding var photoIsPresented: Bool
    
    let post: Post
    let size: CGFloat
    
    var body: some View {
        
        if  post.thumbnail == "image"   ||
            post.thumbnail == "self"    ||
            post.thumbnail == "default"
        {
            Image("no_thumbnail")
                .resizable()
                .frame(width: size, height: size)
        }
        else if let thumbnailUrl = post.thumbnailUrl {
            AsyncImage(url: thumbnailUrl) { image in
                
                Button {
                    photoIsPresented = true
                } label: {
                    image.resizable()
                }
                
            } placeholder: {
                Image("no_thumbnail")
                    .resizable()
                    .frame(width: size, height: size)
            }
            .scaledToFill()
            .frame(width: size, height: size)
        }
        else {
            Image("no_thumbnail")
                .resizable()
                .frame(width: size, height: size)
        }
        
    }
}

struct CompactPostCardView: View {
    
    let post: Post
    let showPin: Bool
    
    @State var photoIsPresented: Bool = false
    
    let dateFormatter = DateFormatter()
    
    init(post: Post, showPin: Bool){
        self.post = post
        self.showPin = showPin
        self.photoIsPresented = photoIsPresented
        
        dateFormatter.dateFormat = "dd/MM/yy"
    }
    
    var body: some View {
            
            VStack(spacing: 0){
            
            if post.stickied && showPin {
                HStack{
                    Image(systemName: "pin.fill")
                        .foregroundColor(Color.green)
                        .rotationEffect(.degrees(45))
                        .padding(5)
                    Text("PINNED BY MODERATORS")
                        .foregroundColor(Color.gray)
                        .bold()
                        .font(.system(size: 10))
                    Spacer()
                }
            }
            
            VStack{
                HStack{
                    NavigationLink {
                        PostView()
                    } label: {
                        Text(post.title)
                            .bold()
                            .padding(.trailing)
                            .frame(width: .infinity, height: 60)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                    PostThumbnailView(photoIsPresented: $photoIsPresented, post: post, size: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                HStack{
                    Button {
                        
                    } label: {
                     Image("arrowshape.up.fill")
                         .foregroundColor(Color.gray)
                    }
                    
                    Text(post.ups.toKNotation())
                        .frame(width: 35, alignment: .leading)
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                    
                    Button {
                        
                    } label: {
                        Image("arrowshape.up.fill")
                            .rotationEffect(.degrees(180))
                            .foregroundColor(Color.gray)
                            //.padding(.leading, 5)
                    }
                    
                    Text(post.formatCreationTime(dateFormatter: dateFormatter))
                        .foregroundColor(Color.gray)
                        .font(.system(size: 12))
                        .bold()
                        .padding(.leading)
                    
                    if post.over18 {
                        NsfwSymbolView()
                    }
                    
                    if post.locked {
                        Image(systemName: "lock")
                            .foregroundColor(Color.gray)
                    }
                    
                    
                    Spacer()
                    Text(post.subreddit)
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                }
            }
        }
        .sheet(isPresented: $photoIsPresented) {
            PhotoViewerView(image: Image("foto_di_prova"))
        }
    
    
    }
    
}

extension Int {
    
    func toKNotation() -> String {
        if(self < 1000){
            return "\(self)"
        }
        
        let div = log10(Float(self))
        
        let letter: String = {
            
            if (div >= 12) {
                return "T"
            }
            if (div >= 9) {
                return "B"
            }
            if (div >= 6) {
                return "M"
            }
            return "K"
        }()
        
        let exp = div - div.truncatingRemainder(dividingBy: 3)
        let num = self / Int(pow(10.0, exp))
        return "\(num)\(letter)"
    }
}

struct CompactPostCardView_Previews: PreviewProvider {
    
    static let postData: [String : Any] = [
        "ups": 100000,
        "downs": 2,
        "likes": 0,
        "created": 0.0,
        "created_utc": 0.0,
        "author": "author",
        "hidden": 0,
        "is_self": 0,
        "locked": 1,
        "num_comments": 20,
        "over_18": 1,
        "score": 8,
        "selftext": "Testo di prova",
        "subreddit": "subreddit",
        "subreddit_id": "1234",
        "thumbnail": "image",
        "title": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
        "permalink": "aaaa",
        "url": "aaaa",
        "stickied": 1
    ]
        
    
    static var previews: some View {
        CompactPostCardView(post: Post(id: nil, name: nil, kind: "", data: postData), showPin: true)
            .previewLayout(.sizeThatFits)
    }
}
