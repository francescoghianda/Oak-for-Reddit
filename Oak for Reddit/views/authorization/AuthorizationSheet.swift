//
//  AuthorizationSheet.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 15/03/23.
//

import SwiftUI

fileprivate struct AuthorizationSheetIntroView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var tabIndex: Int
    
    @State private var buttonSize: CGSize = .zero
    
    var body: some View {
        
        HStack{
            Spacer()
            VStack{
                
                Spacer()
                
                Button {
                    tabIndex = 1
                } label: {
                    Text("Login with Reddit")
                        .padding()
                        .foregroundColor(.white)
                        .font(.bold(.title2)())
                }
                .background(Color.init(hexString: "#FF4500"))
                .cornerRadius(10)
                .highPriorityGesture(DragGesture())
                .gesture(DragGesture())
                .overlay {
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                buttonSize = geo.size
                            }
                    }
                }

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .padding()
                        .foregroundColor(.black)
                        .font(.bold(.title2)())
                }
                .frame(width: buttonSize.width, height: buttonSize.height)
                .background(Color.white)
                .highPriorityGesture(DragGesture())
                .gesture(DragGesture())
                .overlay{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                }
                
                Spacer()
            }
            Spacer()
        }
        .background(.white)
        
        
        
    }
    
}

fileprivate struct AuthorizationSheetWebView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack(){
                Button("Cancel"){
                    dismiss()
                }
                .padding()
                Spacer()
            }
            .background(.ultraThinMaterial)
            
            AuthWebView(url: OAuthManager.shared.buildAuthorizationUrl())
        }
        
    }
}

struct AuthorizationSheet: View {
    
    @State private var tabIndex: Int = 0
    
    var body: some View {
        
        TabView(selection: $tabIndex) {
            
            AuthorizationSheetIntroView(tabIndex: $tabIndex)
                .contentShape(Rectangle())
                .gesture(DragGesture())
                .tag(0)
            
            AuthorizationSheetWebView()
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .gesture(DragGesture())
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea()
        .animation(.spring(), value: tabIndex)
        
    }
    
    
}

struct AuthorizationSheet_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationSheet()
    }
}
