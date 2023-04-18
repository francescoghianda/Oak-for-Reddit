//
//  SearchableView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 17/04/23.
//

import SwiftUI

struct SearchableView<Content: View>: View {
    
    @ViewBuilder var content: Content
    @State var onSearchSubmitHandler: EquatableHandler? = nil
    @State var searchText: String = ""
    
    var body: some View {
        
        content
            .onPreferenceChange(OnSeachSubmitPK.self) {
                onSearchSubmitHandler = $0
            }
            .searchable(text: $searchText)
            .onSubmit(of: .search, {
                onSearchSubmitHandler?.handler()
            })
            .environment(\.searchText, searchText)
        
    }
    
    
}

struct OnSeachSubmitPK: PreferenceKey {
    static var defaultValue: EquatableHandler?

    static func reduce(value: inout EquatableHandler?, nextValue: () -> EquatableHandler?) {
        value = nextValue()
    }
}

struct EquatableHandler: Equatable {
    
    let id: String = UUID().uuidString
    let handler: () -> Void
    
    init(_ handler: @escaping () -> Void){
        self.handler = handler
    }
    
    static func == (lhs: EquatableHandler, rhs: EquatableHandler) -> Bool {
        lhs.id == rhs.id
    }
}

extension View {
    
    func onSearchSubmit(_ value: @escaping () -> Void) -> some View {
        preference(key: OnSeachSubmitPK.self, value: EquatableHandler(value))
    }
}



struct SearchTextKey: EnvironmentKey {
    
    static let defaultValue: String = ""
    
}

extension EnvironmentValues {
    var searchText: String {
        get {
            self[SearchTextKey.self]
        }
        set {
            self[SearchTextKey.self] = newValue
        }
    }
}




