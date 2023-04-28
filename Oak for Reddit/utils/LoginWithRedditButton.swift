//
//  LoginWithRedditButton.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 28/04/23.
//

import SwiftUI

struct LoginWithRedditButton: View {
    
    private var action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        
        Button {
            action()
        } label: {
            
            Label {
                Text("Sign in with Reddit")
                    .foregroundColor(.white)
                    .padding()
            } icon: {
                Image("reddit_logo")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .scaledToFit()
                    .padding(.leading)
            }
            .font(.title2.bold())
            .background(Color(hexString: "#FF4500"))
                

        }
        .cornerRadius(10)
        
    }
}

struct LoginWithRedditButton_Previews: PreviewProvider {
    
    static var previews: some View {
        LoginWithRedditButton {
            print("preview")
        }
        .previewLayout(.sizeThatFits)
    }
}
