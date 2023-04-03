//
//  RefreshableScrollView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 26/03/23.
//

import Foundation
import SwiftUI


struct RefreshableScrollView<Content: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIScrollViewController<Content>
    
    var content: () -> Content
    
    private let coordinator: Coordinator
    

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.coordinator = Coordinator(UIScrollViewController(rootView: self.content()))
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> UIViewControllerType {

        let controller = context.coordinator.controller
        
        controller.scrollView.refreshControl = UIRefreshControl()
        controller.scrollView.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl), for: .valueChanged)
        controller.scrollView.delegate = context.coordinator
        
        return controller
    }
    

    func updateUIViewController(_ viewController: UIViewControllerType, context: UIViewControllerRepresentableContext<Self>) {
        
        viewController.updateContent(self.content)
    }
    
    func makeCoordinator() -> Coordinator {
        self.coordinator
    }
    
    /*private func newContentOffset(_ viewController: UIViewControllerType, newValue: CGPoint) -> CGPoint {
        
        let maxOffsetViewFrame: CGRect = viewController.view.frame
        let maxOffsetFrame: CGRect = viewController.hostingController.view.frame
        let maxOffsetX: CGFloat = maxOffsetFrame.maxX - maxOffsetViewFrame.maxX
        let maxOffsetY: CGFloat = maxOffsetFrame.maxY - maxOffsetViewFrame.maxY
        
        return CGPoint(x: min(newValue.x, maxOffsetX), y: min(newValue.y, maxOffsetY))
    }*/
    
    
    final class Coordinator: NSObject, UIScrollViewDelegate {
        
        let controller: UIViewControllerType
        var onBottomReachedHandler: (() async -> Void)?
        var onRefreshHandler: (() async -> Void)?
        var bottomHandlerIsExecuting: Bool = false
        
        init(_ controller: UIViewControllerType) {
            self.controller = controller
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
            if (bottomEdge >= scrollView.contentSize.height && !bottomHandlerIsExecuting) {
                
                bottomHandlerIsExecuting = true
                
                Task { [weak self] in
                    
                    await self?.onBottomReachedHandler?()
                    self?.bottomHandlerIsExecuting = false
                    
                }
            }
        }
        
        
        @objc func handleRefreshControl() {
            
            Task { [weak self] in
                
                await self?.onRefreshHandler?()
                
                DispatchQueue.main.async { [weak self] in
                    self?.controller.scrollView.refreshControl?.endRefreshing()
                }
                
            }
            
        }

        
    }
    
    func onBottomReached(action: @escaping () async -> Void) -> RefreshableScrollView {
        self.coordinator.onBottomReachedHandler = action
        return self
    }
    
    func refreshable(action: @escaping () async -> Void) -> RefreshableScrollView {
        self.coordinator.onRefreshHandler = action
        return self
    }
    
}

final class UIScrollViewController<Content: View> : UIViewController, ObservableObject {

    let hostingController: UIHostingController<Content>

    lazy var scrollView: UIScrollView = {
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.canCancelContentTouches = true
        scrollView.delaysContentTouches = true
        scrollView.scrollsToTop = false
        scrollView.backgroundColor = .clear
        
        return scrollView
    }()
    

    init(rootView: Content) {
        self.hostingController = UIHostingController<Content>(rootView: rootView)
        self.hostingController.view.backgroundColor = .clear
        super.init(nibName: nil, bundle: nil)
    }
    
    func updateContent(_ content: () -> Content) {
        
        self.hostingController.rootView = content()
        
        self.hostingController.view.layoutIfNeeded()
        
        for view in self.hostingController.view.subviews {
            view.layoutIfNeeded()
        }
        
        var contentSize: CGSize = self.hostingController.view.intrinsicContentSize
        
        contentSize.width = self.scrollView.frame.width
        
        self.hostingController.view.frame.size = contentSize
        self.scrollView.contentSize = contentSize
        
        //self.view.updateConstraintsIfNeeded()
        self.scrollView.addSubview(self.hostingController.view)
        
        self.scrollView.layoutIfNeeded()
        
        self.view.layoutIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        self.addChild(self.hostingController)
        self.view.addSubview(self.scrollView)
        self.createConstraints()
        //self.view.setNeedsUpdateConstraints()
        //self.view.updateConstraintsIfNeeded()
        self.hostingController.view.layoutIfNeeded()
        self.scrollView.layoutIfNeeded()
        self.view.layoutIfNeeded()
        
        hostingController.view.autoresizesSubviews = true
        
        for view in self.hostingController.view.subviews {
            view.layoutIfNeeded()
        }
    }
    
    
    fileprivate func createConstraints() {
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
