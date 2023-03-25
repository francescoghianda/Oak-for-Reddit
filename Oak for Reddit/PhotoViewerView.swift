//
//  PhotoViewerView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 24/03/23.
//

import SwiftUI

struct PhotoViewerView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var offset: CGSize = .zero
    
    let image: Image
    
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            
            ZoomableScrollView{
                image
                    .resizable()
                    .scaledToFit()
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { _ in
                        if abs(offset.height) > 300 {
                            dismiss()
                        } else {
                            offset = .zero
                        }
                    }
            )
            
            VStack{
                HStack{
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "multiply")
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: 30, height: 30)
                            .scaledToFit()
                            .padding()
                    }

                }
                Spacer()
            }
            
            
        }
    }
}

struct PhotoViewerView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoViewerView(image: Image("foto_di_prova"))
    }
}
