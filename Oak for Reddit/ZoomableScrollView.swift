//
//  ZoomableScrollView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 24/03/23.
//

import Foundation
import SwiftUI

struct ZoomableScrollView<Content: View> : UIViewRepresentable {
    
    private let onZoomChangeHandler: ((_ zoomScale: CGFloat) -> Void)?
    
    private var content: Content
    private var zoomEnabled: Bool
    
    private init(content: Content, onZoomChangeHandler: @escaping (_ zoomScale: CGFloat) -> Void, zoomEnabled: Bool){
        self.content = content
        self.onZoomChangeHandler = onZoomChangeHandler
        self.zoomEnabled = zoomEnabled
    }
    
    init(zoomEnabled: Bool = true, @ViewBuilder content: @escaping  () -> Content){
        self.content = content()
        self.onZoomChangeHandler = nil
        self.zoomEnabled = zoomEnabled
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = zoomEnabled ? 20 : 1
        scrollView.minimumZoomScale = 1
        context.coordinator.onZoomChange = onZoomChangeHandler
        
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
        var onZoomChange: ((_ zoomScale: CGFloat) -> Void)?

        init(hostingController: UIHostingController<Content>) {
          self.hostingController = hostingController
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
          return hostingController.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            onZoomChange?(scrollView.zoomScale)
        }
        
        
    }
    
    func onZoomChange(_ perform: @escaping (_ zoomScale: CGFloat) -> Void) -> ZoomableScrollView<Content> {
        return ZoomableScrollView(content: content, onZoomChangeHandler: perform, zoomEnabled: zoomEnabled)
    }
}
