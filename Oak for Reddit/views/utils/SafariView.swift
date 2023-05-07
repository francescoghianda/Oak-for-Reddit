//
//  SafariView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 31/03/23.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    
    @Environment(\.dismiss) var dismiss
    
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.delegate = context.coordinator
        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.dismissAction = dismiss
        return coordinator
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var dismissAction: DismissAction?

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            dismissAction?()
        }
    }

        

}
