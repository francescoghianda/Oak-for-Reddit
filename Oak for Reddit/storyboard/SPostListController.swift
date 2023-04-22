//
//  SPostListController.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 29/03/23.
//



import Foundation
import UIKit
import SwiftUI

struct SPostListView<Content: View>: UIViewControllerRepresentable {
    
    @ViewBuilder let content: () -> Content
    
    private var hostingController: UIHostingController<Content>
    //private let hostingController: UIHostingController<Content>
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.hostingController = UIHostingController(rootView: content())
    }
    
    func makeUIViewController(context: Context) -> SPostListController {
        //let storyboardBundle = Bundle(for: SPostListController.self)
        let storyboard = UIStoryboard(name: "SPostList", bundle: Bundle.main)
        
        let vc = storyboard.instantiateViewController(identifier: "PostList") as! SPostListController
        
        vc.addChild(hostingController)
        
        hostingController.view.backgroundColor = .green
        
        vc.onViewDidLoad = {
            vc.stackView.insertArrangedSubview(hostingController.view, at: 0)
            //vc.stackView.addArrangedSubview(hostingController.view)
        }
        //vc.addChild(hostingController)
        
        return vc
    }
    
    func updateUIViewController(_ vc: SPostListController, context: Context) {
        
        print("update")
        //vc.updateView(content: content)
        //vc.stackView.removeArrangedSubview(hostingController.view)
                
        hostingController.rootView = content()
        
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        hostingController.view.invalidateIntrinsicContentSize()
        
        //vc.stackView.addArrangedSubview(hostingController.view)
        
        vc.stackView.insertArrangedSubview(hostingController.view, at: 0)
        
        vc.stackView.setNeedsLayout()
        vc.stackView.layoutIfNeeded()
        vc.stackView.invalidateIntrinsicContentSize()
        
        //vc.stackView.addSubview(hostingController.view)
        
        
        //vc.stackView.addArrangedSubview(vc.hostingController!.view)
        
        /*hostingController.rootView = content()
        hostingController.view.frame.size.width = vc.stackView.frame.size.width
        hostingController.view.layoutIfNeeded()
        
        vc.stackView.addSubview(hostingController.view)*/
        
    }
    
}


class SPostListController: UIViewController {
    
    @IBOutlet var stackView: UIStackView!
    
    var onViewDidLoad: (() -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.distribution = .fill
        
        onViewDidLoad?()
    }
    
}
