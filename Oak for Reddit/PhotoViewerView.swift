//
//  PhotoViewerView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 24/03/23.
//

import SwiftUI


struct PhotoViewerView: View {
    
    @Environment(\.dismiss) var dismiss
    
    //@EnvironmentObject var mediaDataModel: MediaSheetDataModel
    
    @State var offset: CGSize = .zero
    @State var imageSaved: Bool = false
    
    //@StateObject private var loader: PhotoViewerLoader = PhotoViewerLoader()
    
    @State var image: UIImage?
    let imageUrl: URL?
    
    
    init(image: UIImage){
        self.imageUrl = nil
        self.image = image
    }
    
    init(url: URL?) {
        self.imageUrl = url
        self.image = nil
    }
    
    var body: some View {
        
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if let image = self.image {
                ZoomableScrollView {
                    Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                }
            }
            else if let url = self.imageUrl {
                
                AsyncUIImage(url: url, image: self.$image) { image, error in
                    
                    if error != nil {
                        
                        VStack{
                            Image(systemName: "exclamationmark.triangle")
                            Text("Error loading image")
                                .foregroundColor(Color.gray)
                        }
                        
                    }
                    else {
                        ProgressView()
                    }
                    
                }
                
            }
            
            
            VStack{
                HStack{
                    
                    if imageSaved {
                        
                        HStack{
                            Image(systemName: "checkmark.seal")
                                .resizable()
                                .foregroundColor(Color.green)
                                .frame(width: 24, height: 24)
                                .scaledToFit()
                                .padding()
                            Text("Photo saved")
                                .foregroundColor(Color.green)
                                .bold()
                                .font(.title3)
                        }
                        
                    }
                    else {
                        Button {
                            if let image = self.image {
                                ImageSaver {
                                    withAnimation {
                                        imageSaved = true
                                    }
                                }
                                .saveImage(image: image)
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .resizable()
                                .foregroundColor(self.image == nil ? Color.gray : Color.white)
                                .frame(width: 24, height: 24)
                                .scaledToFit()
                                .padding()
                        }
                        .disabled(self.image == nil)
                    }
                    
                    Spacer()

                }
                Spacer()
            }
            
            
        }
    }
}

struct PhotoViewerView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoViewerView(image: UIImage(named: "foto_di_prova")!)
    }
}
