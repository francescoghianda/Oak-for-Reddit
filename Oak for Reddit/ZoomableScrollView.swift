//
//  ZoomableScrollView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 24/03/23.
//

import Foundation
import SwiftUI

struct ZoomableScrollView<Content: View> : UIViewRepresentable {
    
    private var content: Content
    
    init(@ViewBuilder content: () -> Content){
        self.content = content()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true

        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        scrollView.addSubview(hostedView)

        return scrollView
      }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        
        var hostingController: UIHostingController<Content>

        init(hostingController: UIHostingController<Content>) {
          self.hostingController = hostingController
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
          return hostingController.view
        }
        
        
    }
}