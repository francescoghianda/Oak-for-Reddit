//
//  ToolbarSelector.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 23/03/23.
//

import SwiftUI

struct ToolbarSelector<T: CaseIterable & Hashable & Identifiable, V: View>: View
where T.AllCases: RandomAccessCollection
{
    let bind: Binding<T>
    @ViewBuilder let caseToLabel: (T) -> V
    @ViewBuilder let label: () -> V
    
    var body: some View{
        
        Menu {
            
            ForEach(T.allCases, id: \.id) { item in
                
                Button {
                    bind.wrappedValue = item
                } label: {
                    caseToLabel(item)
                }
                
            }

        } label: {
            label()
        }
    }
}

/*struct ToolbarSelctor_Previews: PreviewProvider {
    
    @State var order: PostListingOrder = .new
    
    static var previews: some View {
        
        ToolbarSelector(bind: $order) { item in
            switch item {
            case .best:
                Label("Best", systemImage: "fan.desk")
            case .hot:
                Label("Hot", systemImage: "fan.desk")
            case .new:
                Label("New", systemImage: "fan.desk")
            case .rising:
                Label("Rising", systemImage: "fan.desk")
            case .top:
                Label("Top", systemImage: "fan.desk")
            case .controversial:
                Label("Controversial", systemImage: "fan.desk")
            }
        } label: {
            Label("Order", systemImage: "arrow.up.arrow.down")
        }

    }
}*/

