//
//  InterfaceSettingsView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/04/23.
//

import SwiftUI

private struct CheckedButton<Content: View>: View {
    
    let checked: Bool
    let action: () -> Void
    @ViewBuilder var label: Content
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack{
                label
                Spacer()
                if checked {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

private struct ExpandableMenu<Content: View, Label: View>: View {
    
    @State var expanded: Bool = false
    @ViewBuilder var content: Content
    @ViewBuilder var label: Label
    
    var body: some View {
        
        Button {
            withAnimation {
                expanded.toggle()
            }
        } label: {
            label
        }
        
        if expanded {
            
            List {
                content
            }
            .padding(.leading, 20)
            
        }
        
    }
    
}


private struct PostOrderPicker: View {
    
    @Binding var selected: PostListingOrder
    
    var body: some View{
        
        Form {
            
            ForEach(PostListingOrder.allCases) { sort in
                
                switch sort {
                case .top, .controversial:
                    
                    let splitted = selected.rawValue.split(separator: PostListingOrder.rawValueSeparator)
                    let selectedSort = splitted.first ?? ""
                    let selectedRange = splitted[safe: 1] ?? ""
                    
                    
                    ExpandableMenu {
                        ForEach(TimeRange.allCases) { range in
                            
                            let checkedRange = (selectedRange == range.rawValue) && (selectedSort == sort.rawValueNoRange)
                            
                            CheckedButton(checked: checkedRange) {
                                
                                if case .top = sort {
                                    selected = PostListingOrder.top(range: range)
                                }
                                else {
                                    selected = PostListingOrder.controversial(range: range)
                                }
                                
                            } label: {
                                Label {
                                    Text(LocalizedStringKey(range.rawValue))
                                        .foregroundColor(.primary)
                                } icon: {
                                    Image(systemName: range.systemImage)
                                        .foregroundColor(range.color)
                                }
                            }
                        }
                        
                    } label: {
                        HStack{
                            Label {
                                Text(LocalizedStringKey(sort.text))
                            } icon: {
                                Image(systemName: sort.systemImage)
                                    .foregroundColor(sort.color)
                            }
                            //Label(sort.displayText, systemImage: sort.systemImage)
                            Spacer()
                            if selectedSort == sort.rawValueNoRange {
                                Image(systemName: "checkmark")
                            }
                        }
                    }

                    
                default:
                    CheckedButton(checked: sort.rawValue == selected.rawValue) {
                        selected = sort
                    } label: {
                        Label {
                            Text(LocalizedStringKey(sort.text))
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: sort.systemImage)
                                .foregroundColor(sort.color)
                        }
                    }

                }
                
            }
            
        }
        .navigationBarTitle("Posts order")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
}

struct PostOrderPicker_Previews: PreviewProvider {
    
    @State static var selected: PostListingOrder = .best
    
    static var previews: some View {
        
        Form {
            PostOrderPicker(selected: $selected)
        }
        
        
    }
    
}

struct LabelWithValue: View {
    
    let text: LocalizedStringKey
    let value: String
    
    init(_ text: LocalizedStringKey, value: String){
        self.text = text
        self.value = value
    }
    
    var body: some View {
        HStack{
            Text(text)
            Spacer()
            Text(LocalizedStringKey(value))
                .foregroundColor(.gray)
        }
    }
    
}


fileprivate struct SubredditPreferredOrderPicker: View {
    
    @Environment(\.managedObjectContext) private var moc
    //@ObservedObject var settings: Settings
    //@EnvironmentObject var userPreferences: UserPreferences
    @ObservedObject var userPreferences = UserPreferences.shared
    
    var body: some View {
        Form {
            Picker("", selection: $userPreferences.subredditsPreferredOrder) {
                ForEach(SubredditListingOrder.allCases) { sort in
                    
                    Label {
                        Text(LocalizedStringKey(sort.text))
                            .foregroundColor(.primary)
                    } icon: {
                        sort.icon
                            .foregroundColor(sort.color)
                    }
                    .tag(sort)
                        
                }
            }
            .pickerStyle(.inline)
            .onChange(of: userPreferences.subredditsPreferredOrder) { _ in
                if moc.hasChanges {
                    try? moc.save()
                }
            }
        }
        .navigationTitle("Subreddits order")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

fileprivate struct CommentsPreferredOrderPicker: View {
    
    @Environment(\.managedObjectContext) private var moc
    //@EnvironmentObject var userPreferences: UserPreferences
    @ObservedObject var userPreferences = UserPreferences.shared
    
    var body: some View {
        Form {
            Picker("", selection: $userPreferences.commentsPreferredOrder) {
                ForEach(CommentsOrder.allCases) { sort in
                    
                    Label {
                        Text(LocalizedStringKey(sort.text))
                            .foregroundColor(.primary)
                    } icon: {
                        sort.icon
                            .foregroundColor(sort.color)
                    }
                    .tag(sort)
                        
                }
            }
            .pickerStyle(.inline)
            .onChange(of: userPreferences.commentsPreferredOrder) { _ in
                if moc.hasChanges {
                    try? moc.save()
                }
            }
        }
        .navigationTitle("Comments order")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}


struct InterfaceSettingsView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    //@EnvironmentObject var userPreferences: UserPreferences
    @ObservedObject var userPreferences: UserPreferences = UserPreferences.shared
    
    private func postOrderLabel() -> some View {
        let order = userPreferences.postPreferredOrder
        let range: String? = {
            switch order {
            case .top(let range):
                return range.rawValue
            case .controversial(let range):
                return range.rawValue
            default:
                return nil
            }
        }()
        
        let valueStr = range != nil ? "\(order.text) (\(range!))" : order.text
        
        return LabelWithValue("Posts preferred order", value: valueStr)
    }
    
    var body: some View {
        
        Form {
            
            Section(header: Text("Subreddits").textCase(.uppercase)) {
                NavigationLink {
                    SubredditPreferredOrderPicker()
                } label: {
                    LabelWithValue("Subreddits preferred order", value: userPreferences.subredditsPreferredOrder.text)
                }
            }
            
            Section(header: Text("Posts").textCase(.uppercase)) {
                NavigationLink {
                    PostOrderPicker(selected: $userPreferences.postPreferredOrder)
                        .onChange(of: userPreferences.postPreferredOrder) { _ in
                            save()
                        }
                } label: {
                    postOrderLabel()
                }
                
                HStack{
                    Text("Post view mode")
                    Picker("", selection: $userPreferences.postsCardSize) {
                        
                        Text("Compact")
                            .tag(PostCardSize.compact)
                        
                        Text("Large")
                            .tag(PostCardSize.large)
                        
                    }
                    .onChange(of: userPreferences.postsCardSize) { _ in
                        save()
                    }
                }
                
                Toggle("Load new posts automatically", isOn: $userPreferences.loadNewPostsAutomatically)
                    .onChange(of: userPreferences.loadNewPostsAutomatically) { newValue in
                        save()
                    }
                
                VStack(alignment: .leading){
                    Picker("Images load quality", selection: $userPreferences.mediaQuality) {
                        ForEach(PostPreviewResolution.allCases) { res in
                            Text(LocalizedStringKey(res.text))
                                .tag(res)
                        }
                    }
                    .onChange(of: userPreferences.mediaQuality) { _ in
                        save()
                    }
                    
                    if userPreferences.mediaQuality == .original {
                        Text("Loading images with original relosolution may cause slow application performace and higher loading time.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section(header: Text("Comments").textCase(.uppercase)) {
                NavigationLink {
                    CommentsPreferredOrderPicker()
                } label: {
                    LabelWithValue("Comments preferred order", value: userPreferences.commentsPreferredOrder.text)
                }
                
                HStack{
                    Text("Comments view mode")
                    Picker("", selection: $userPreferences.commentsViewMode) {
                        
                        Text("Classic")
                            .tag(CommentsViewMode.classic)
                        
                        Text("Light")
                            .tag(CommentsViewMode.light)
                        
                    }
                    .onChange(of: userPreferences.commentsViewMode) { _ in
                        save()
                    }
                }
            }
            
        }
        .navigationTitle("Interface")
        
        
    }
    
    private func save() {
        if moc.hasChanges {
            try? moc.save()
        }
    }
}
