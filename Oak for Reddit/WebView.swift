//
//  WebView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 16/03/23.
//

import SwiftUI
import WebKit
import SafariServices
 
final class WebView: NSObject, WKNavigationDelegate, UIViewRepresentable {
 
    var url: URL
    
    init(url: URL){
        self.url = url
    }
 
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        
        view.navigationDelegate = self
        
        return view
    }
    
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.customUserAgent = RedditApi.USER_AGENT
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        let app = UIApplication.shared
        let url = navigationAction.request.url
        
        if (url!.scheme == OAuthManager.CALLBACK_URL_SCHEME) && app.canOpenURL(url!) {
            app.open(url!, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}
