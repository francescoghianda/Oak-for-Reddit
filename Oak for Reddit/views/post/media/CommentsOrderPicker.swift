//
//  CommentsOrderPicker.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import SwiftUI

struct CommentsOrderPicker: View {
    
    @Binding var commentsOrder: CommentsOrder
    @Binding var showPicker: Bool
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0){
            
            ForEach(CommentsOrder.allCases, id: \.id) { item in
                
                Button(action: {
                    commentsOrder = item
                    showPicker.toggle()
                    
                }, label: {
                    VStack(spacing: 0) {
                        HStack{
                            
                            
                            Rectangle()
                                .foregroundColor(.clear)
                                .background {
                                    if item == commentsOrder {
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(.white, .blue)
                                    }
                                }
                                .frame(width: 16, height: 16)
                            
                            Text(item.viewString)
                                .padding(.leading)
                            
                            Spacer()
                            
                        }
                        .foregroundColor(.primary)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 10)
                        
                        if item != CommentsOrder.allCases.last{
                            Divider()
                        }
                        
                    }
                })
                
                
            }
            
        }
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        
    }
    
}
