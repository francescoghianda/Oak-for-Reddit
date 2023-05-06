//
//  LoggedActionButton.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 06/05/23.
//

import SwiftUI

struct LoggedActionButton<Label: View>: View {
    
    private var action: () -> Void
    @ViewBuilder private var label: () -> Label
    
    init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }
    
    var body: some View {
        
        Button {
            if let _ = AccountsManager.shared.logged {
                action()
            }
            else {
                OAuthManager.shared.authenticate { error in
                    if error == nil {
                        action()
                    }
                }
            }
        } label: {
            label()
        }

    }
}
