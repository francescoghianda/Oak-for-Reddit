//
//  SettingsView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/04/23.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: Settings.entity(), sortDescriptors: [])
    private var settings: FetchedResults<Settings>
    
    var body: some View {
        
        
        
        NavigationView {
            
            if let settings: Settings = settings.first {
                
                List {
                    
                    NavigationLink {
                        
                    } label: {
                        Label("Account", systemImage: "person.crop.circle")
                    }
                    
                    NavigationLink {
                        InterfaceSettingsView(settings: settings)
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
        
        
        
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
