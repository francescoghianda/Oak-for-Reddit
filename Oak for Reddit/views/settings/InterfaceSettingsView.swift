//
//  InterfaceSettingsView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/04/23.
//

import SwiftUI

struct InterfaceSettingsView: View {
    
    @ObservedObject var settings: Settings
    
    
    var body: some View {
        
        List {
            
            Section("Subreddits") {
                
                //Picker("Preferred sort", selection: , content: <#T##() -> _#>)
                
            }
            
            Section("Posts") {
                
            }
            
            
        }
        
        
    }
}
