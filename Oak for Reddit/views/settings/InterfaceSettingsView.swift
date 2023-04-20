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
                                    Text(range.rawValue)
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
                                Text(sort.text)
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
                            Text(sort.text)
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
    
    let text: String
    let value: String
    
    init(_ text: String, value: String){
        self.text = text
        self.value = value
    }
    
    var body: some View {
        HStack{
            Text(text)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
    
}


fileprivate struct SubredditPreferredOrderPicker: View {
    
    @Environment(\.managedObjectContext) private var moc
    //@ObservedObject var settings: Settings
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        Form {
            Picker("", selection: $userPreferences.subredditsPreferredOrder) {
                ForEach(SubredditListingOrder.allCases) { sort in
                    
                    Label {
                        Text(sort.text)
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
                try? moc.save()
            }
        }
        .navigationTitle("Subreddits order")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

fileprivate struct CommentsPreferredOrderPicker: View {
    
    @Environment(\.managedObjectContext) private var moc
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        Form {
            Picker("", selection: $userPreferences.commentsPreferredOrder) {
                ForEach(CommentsOrder.allCases) { sort in
                    
                    Label {
                        Text(sort.text)
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
                try? moc.save()
            }
        }
        .navigationTitle("Comments order")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}


struct InterfaceSettingsView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @EnvironmentObject var userPreferences: UserPreferences
    
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
            
            Section("SUBREDDITS") {
                NavigationLink {
                    SubredditPreferredOrderPicker()
                } label: {
                    LabelWithValue("Subreddits preferred order", value: userPreferences.subredditsPreferredOrder.text)
                }
            }
            
            Section("POSTS") {
                NavigationLink {
                    PostOrderPicker(selected: $userPreferences.postPreferredOrder)
                        .onChange(of: userPreferences.postPreferredOrder) { _ in
                            try? moc.save()
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
                    .pickerStyle(.segmented)
                    .onChange(of: userPreferences.postsCardSize) { _ in
                        try? moc.save()
                    }
                }
                
                Toggle("Load new posts automatically", isOn: $userPreferences.loadNewPostsAutomatically)
                    .onChange(of: userPreferences.loadNewPostsAutomatically) { newValue in
                        try? moc.save()
                    }
            }
            
            Section("COMMENTS") {
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
                    .pickerStyle(.segmented)
                    .onChange(of: userPreferences.commentsViewMode) { _ in
                        try? moc.save()
                    }
                }
            }
            
        }
        .navigationTitle("Interface")
        
        
    }
}
