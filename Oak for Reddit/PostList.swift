//
//  PostList.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 28/03/23.
//

import Foundation
import UIKit
import SwiftUI

struct PostList<Content: View>: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = PostListController<Content>
    
    private let controller: PostListController<Content>
    
    @ViewBuilder private var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.controller = PostListController(content: content)
    }
    
    func makeUIViewController(context: Context) -> PostListController<Content> {
        return self.controller
    }
    
    func updateUIViewController(_ uiViewController: PostListController<Content>, context: Context) {
        uiViewController.updateView(content: self.content)
    }
    
    func refreshable(_ action: @escaping () async -> Void) -> PostList {
        self.controller.refreshHandler = action
        return self
    }
    
    func onBottomReached(_ action: @escaping () async -> Void) -> PostList {
        self.controller.bottomReachedHandler = action
        return self
    }
    
    
}


class PostListController<Content: View>: UIViewController, UIScrollViewDelegate {
    
    lazy var scrollView: UIScrollView = {
       
        let view = UIScrollView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        view.backgroundColor = .blue
        return view
    }()
    
    lazy var contentView: UIView = {
        
        let view = UIView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackView: UIStackView = {
       
        let view = UIStackView()
        view.isOpaque = false
        view.contentMode = .scaleToFill
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var hostingController: UIHostingController<Content>
    
    let content: () -> Content
    
    var refreshHandler: (() async -> Void)?
    var bottomReachedHandler: (() async -> Void)?
    var bottomReachedHandlerIsExecuting: Bool = false
    
    init(content: @escaping () -> Content) {
        self.content = content
        self.hostingController = UIHostingController(rootView: content())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateView(content: () -> Content) {
        
        print("update")
        
        stackView.removeArrangedSubview(hostingController.view)
        
        hostingController.rootView = content()
        
        //self.hostingController.view.layoutIfNeeded()
        stackView.addArrangedSubview(hostingController.view)
        
        stackView.layoutIfNeeded()
        
        //self.hostingController.view.updateConstraintsIfNeeded()
        
        //adjustSizes()
        
        //self.scrollView.addSubview(self.hostingController.view)
        
        
        //self.view.updateConstraintsIfNeeded()
        //scrollView.layoutIfNeeded()
        
    }
    
    @objc func handleRefreshControl() {
        
        
        Task { [weak self] in
            
            await self?.refreshHandler?()
            
            DispatchQueue.main.async { [weak self] in
                self?.scrollView.refreshControl?.endRefreshing()
            }
            
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height && !bottomReachedHandlerIsExecuting) {
            
            bottomReachedHandlerIsExecuting = true
            
            Task { [weak self] in
                
                await self?.bottomReachedHandler?()
                self?.bottomReachedHandlerIsExecuting = false
                
            }
        }
    }
    
    override func viewDidLoad() {
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            //contentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(PostListController.handleRefreshControl), for: .valueChanged)
        
        hostingController.view.backgroundColor = .clear
        
        self.addChild(hostingController)
        
        stackView.addArrangedSubview(hostingController.view)
        
        /*NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: stackView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])*/
        
        //scrollView.frame.size = view.frame.size
        
        //hostingController.view.layoutIfNeeded()
        
        //adjustSizes()
        
        //scrollView.addSubview(hostingController.view)
        
        //scrollView.layoutIfNeeded()
        
    }
    
    func adjustSizes() {
        var contentSize = hostingController.view.intrinsicContentSize
        
        contentSize.width = view.frame.width
        
        hostingController.view.frame.size = contentSize
        
        scrollView.contentSize = contentSize
        //scrollView.contentSize.height += 200
    }
    
}


