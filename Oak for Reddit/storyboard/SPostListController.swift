//
//  SPostListController.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 29/03/23.
//

import Foundation
import UIKit
import SwiftUI

struct SPostListView: UIViewControllerRepresentable {
    
    //@ViewBuilder let content: () -> Content
    
    @ViewBuilder let content: () -> PostStackView
    //private let hostingController: UIHostingController<Content>
    
    init(@ViewBuilder content: @escaping () -> PostStackView) {
        
        self.content = content
    }
    
    func makeUIViewController(context: Context) -> SPostListController {
        //let storyboardBundle = Bundle(for: SPostListController.self)
        let storyboard = UIStoryboard(name: "SPostList", bundle: Bundle.main)
        
        let vc = storyboard.instantiateViewController(identifier: "PostList") as! SPostListController
        
        vc.hostingController = UIHostingController(rootView: content())
        //vc.addChild(hostingController)
        
        return vc
    }
    
    func updateUIViewController(_ vc: SPostListController, context: Context) {
        
        print("update")
        //vc.updateView(content: content)
        //vc.stackView.removeArrangedSubview(hostingController.view)
        
        vc.stackView.removeArrangedSubview(vc.hostingController!.view)
        
        vc.hostingController?.rootView = content()
        
        vc.hostingController?.view.layoutIfNeeded()
        
        vc.stackView.addArrangedSubview(vc.hostingController!.view)
        
        /*hostingController.rootView = content()
        hostingController.view.frame.size.width = vc.stackView.frame.size.width
        hostingController.view.layoutIfNeeded()
        
        vc.stackView.addSubview(hostingController.view)*/
        
    }
    
}


class SPostListController: UIViewController {
    
    @IBOutlet var stackView: UIStackView!
    
    var hostingController: UIHostingController<PostStackView>?
    
    func removePostCards() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if hostingController != nil {
            
            self.addChild(hostingController!)
            hostingController!.view.backgroundColor = .green
            stackView.addArrangedSubview(hostingController!.view)
        }

    }
    
}
