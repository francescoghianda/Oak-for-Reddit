//
//  SettingsView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/04/23.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        
        List {
            
            NavigationLink{
                AccountInfoView()
            } label: {
                Label("Account", systemImage: "person.crop.circle")
            }
            
            NavigationLink {
                InterfaceSettingsView()
            } label: {
                Label("Interface", systemImage: "paintbrush.pointed.fill")
            }
            
            NavigationLink {
                
            } label: {
                Label("Notifications", systemImage: "music.note")
            }
            
        }
        .navigationTitle("Settings")
        
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
        .navigationViewStyle(.stack)
    }
}
