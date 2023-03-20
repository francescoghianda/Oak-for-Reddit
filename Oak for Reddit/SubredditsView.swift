//
//  Subreddits.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 17/03/23.
//

import SwiftUI

struct SubredditScrollView<Content: View>: UIViewRepresentable{
    
    //var width : CGFloat
    //var height : CGFloat
    
    @ViewBuilder let content: () -> Content
        
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
        
    func makeUIView(context: Context) -> UIScrollView {
        
        let control = UIScrollView()
        control.delegate = context.coordinator
        let childView = UIHostingController(rootView: content())
        control.addSubview(childView.view)
        
        /*control.refreshControl = UIRefreshControl()
        control.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl), for: .valueChanged)
        control.delegate = context.coordinator
        
        let childView = UIHostingController(rootView: content())
        //childView.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        control.addSubview(childView.view)*/
        return control
        
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
    
        var control: SubredditScrollView<Content>
        init(_ control: SubredditScrollView) {
            self.control = control
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
                print("bottom reached")
            }
        }
        
        @objc func handleRefreshControl(sender: UIRefreshControl) {
            sender.endRefreshing()
        }
    }
}

struct SubredditsView: View {
    
    @StateObject var api = SubrettitApi(redditApi: RedditApi.shared)
    
    var body: some View {
        NavigationView{
            
            GeometryReader{ geometry in
                
                ScrollView{

                    LazyVStack {
                        ForEach(api.subreddits) { subreddit in
                            SubredditItemView(subreddit: subreddit)
                        }
                        Button("Load more") {
                            api.loadMore()
                        }

                        /*ForEach(1..<20) { index in
                            Rectangle()
                                .frame(width: .infinity, height: 100)
                                .foregroundColor(Color.blue)
                                .onAppear {
                                    
                                        print(geometry.safeAreaInsets.top)
                                    
                                }
                        }*/
                    }
                    .padding()

                }
            }
            .navigationTitle("Subreddits")
            .toolbar {
                HStack{
                    Button {
                        api.load()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                    Picker("Order", selection: $api.order) {
                        Label("Default", systemImage: "suit.club.fill").tag(SubredditListingOrder.DEFAULT)
                        Label("Popular", systemImage: "flame").tag(SubredditListingOrder.POPULAR)
                        Label("New", systemImage: "bolt.fill").tag(SubredditListingOrder.NEW)
                    }

                    
                }
            }
            
        }
    }
}

class ScrollViewOffsetPreferenceKey: PreferenceKey{
    
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout Value, nextValue: () -> Value){
        value = nextValue()
    }
    
}

struct Subreddits_Previews: PreviewProvider {
    static var previews: some View {
        SubredditsView()
    }
}
