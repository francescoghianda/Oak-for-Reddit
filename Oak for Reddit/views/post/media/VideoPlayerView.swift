//
//  VideoPlayerView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 26/03/23.
//

import SwiftUI
import AVKit
import WebKit

struct RedditVideoPlayer: UIViewControllerRepresentable {
    
    //var player: AVPlayer
    var url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
        let controller = AVPlayerViewController()
                
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer(playerItem: item)
        //let looper = AVPlayerLooper(player: player, templateItem: item)
        
        player.actionAtItemEnd = .none
        
        controller.player = player
        controller.videoGravity = .resizeAspect//.resizeAspectFill
        
        controller.showsPlaybackControls = true
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct EmbedVideoPlayer: UIViewRepresentable {
    
    private static let styleString = "<style> * { margin: 0; padding: 0; } html, body { width: 100%; height: 100%; } </style>"
    
    let html: String
    
    init(media: Media.Embed) {
        guard let html = media.html else {
            self.html = ""
            return
        }
        
        self.html = EmbedVideoPlayer.styleString + html
            .replacingOccurrences(of: String(media.width), with: "100%")
            .replacingOccurrences(of: String(media.height), with: "100%")
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
    
}

struct VideoPlayerView: View {
    
    let media: Media
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if case .unknown = media {
                Text("Error")
                    .foregroundColor(Color.white)
            }
            else {
                switch media {
                case .redditVideo(let data):
                    RedditVideoPlayer(url: data.hlsUrl!)
                    
                case .embed(let data):
                    EmbedVideoPlayer(media: data)
                        .frame(width: CGFloat(data.width), height: CGFloat(data.height))
                        .scaledToFit()
                        
                case .unknown:
                    Rectangle()
                }
            }
            
        }
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    
    static let data: [String : Any] = [
        "reddit_video": [
            "bitrate_kbps": 1200,
            "dash_url": "https://v.redd.it/o7ckl9gcjvpa1/DASHPlaylist.mpd?a=1682335733%2CY2NhODRjMmI4OTg3YzEyNDdiMjEyZjE4MzE0MDdhOTIzYWJmYjA0YzljNDBkZGVkZmUyMzcyOTUwMThiMWYxYw%3D%3D&amp;v=1&amp;f=sd",
            "duration": 29,
            "fallback_url": "https://v.redd.it/o7ckl9gcjvpa1/DASH_480.mp4?source=fallback",
            "hls_url": "https://v.redd.it/o7ckl9gcjvpa1/HLSPlaylist.m3u8?a=1682335733%2CM2ZjYWFiNWI2NDUxYmY2ZjE0YjNmMDc2Zjc1NjMwMTE3YzIzMzYzMWVlYmE0MjIwYjMzNWQxNGI0YjE1MGE4Yw%3D%3D&amp;v=1&amp;f=sd",
            "is_gif": 0,
            "scrubber_media_url": "https://v.redd.it/o7ckl9gcjvpa1/DASH_96.mp4",
            "width": 384,
            "height": 480
        ]
    ]
    
    static let dataEmbed: [String : Any] = [
        "oembed": [
            "type": "video",
            "title": "Shut up about the F-35",
            "provider_name": "YouTube",
            "provider_url": "https://www.youtube.com/",
            "html": "&lt;iframe width=\"356\" height=\"200\" src=\"https://www.youtube.com/embed/CH8o9DIIXqI?feature=oembed&amp;enablejsapi=1\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" allowfullscreen title=\"Shut up about the F-35\"&gt;&lt;/iframe&gt;",
            "width": 356,
            "height": 200
        ]
    ]
    
    
    static var previews: some View {
        VideoPlayerView(media: Media.build(from: data))
    }
}
