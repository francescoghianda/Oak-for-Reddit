//
//  FetchErrorView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 03/05/23.
//

import SwiftUI

struct FetchErrorView: View {
    
    let error: FetchError
    let reload: (() -> Void)?
    
    init(error: FetchError, reloadAction: (() -> Void)? = nil) {
        self.error = error
        self.reload = reloadAction
    }
    
    var body: some View {
        VStack(spacing: 30) {
            icon()
                .frame(width: 48, height: 48)
                
            text()
                .font(.title3.bold())
                .foregroundColor(.gray)
            
            if case .forbidden = error, AccountsManager.shared.logged == nil {
                
                LoginWithRedditButton {
                    OAuthManager.shared.authenticate { error in
                        if error == nil {
                            DispatchQueue.main.async {
                                reload?()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func icon() -> some View {
        switch error {
        case .forbidden:
            Image(systemName: "minus.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white, .red)
        case .no_connection:
            Image(systemName: "wifi.slash")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
        default:
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .foregroundColor(.yellow)
        }
    }
    
    @ViewBuilder
    func text() -> some View {
        switch error {
        case .forbidden:
            Text("YOU ARE NOT ALLOWED\nTO VIEW THIS CONTENT")
        case .no_connection:
            Text("CONNECTION ERROR")
        default:
            Text("AN UNEXPECTED ERROR OCCURED")
        }
    }
}

struct FetchErrorView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        Group {
            FetchErrorView(error: .forbidden)
        }
    }
}
