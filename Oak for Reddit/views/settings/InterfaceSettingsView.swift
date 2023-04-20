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
    
    @Binding var selected: String
    
    var body: some View{
        
        Form {
            
            ForEach(PostListingOrder.allCases) { sort in
                
                switch sort {
                case .top, .controversial:
                    
                    let splitted = selected.split(separator: PostListingOrder.rawValueSeparator)
                    let selectedSort = splitted.first ?? ""
                    let selectedRange = splitted[safe: 1] ?? ""
                    
                    
                    ExpandableMenu {
                        ForEach(TimeRange.allCases) { range in
                            
                            let checkedRange = (selectedRange == range.rawValue) && (selectedSort == sort.rawValueNoRange)
                            
                            CheckedButton(checked: checkedRange) {
                                
                                if case .top = sort {
                                    selected = PostListingOrder.top(range: range).rawValue
                                }
                                else {
                                    selected = PostListingOrder.controversial(range: range).rawValue
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
                                Text(sort.displayText)
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
                    CheckedButton(checked: sort.rawValue == selected) {
                        selected = sort.rawValue
                    } label: {
                        Label {
                            Text(sort.displayText)
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
    
    @State static var selected: String = "best"
    
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
    @ObservedObject var settings: Settings
    
    var body: some View {
        Form {
            Picker("", selection: $settings.subredditPreferredSort) {
                ForEach(SubredditListingOrder.allCases) { sort in
                    
                    Label {
                        Text(sort.displayText)
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: sort.systemImage)
                            .foregroundColor(sort.color)
                    }
                    .tag(sort)
                        
                }
            }
            .pickerStyle(.inline)
            .onChange(of: settings.subredditPreferredSort) { _ in
                try? moc.save()
            }
        }
        .navigationTitle("Subreddits order")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

fileprivate struct CommentsPreferredOrderPicker: View {
    
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var settings: Settings
    
    var body: some View {
        Form {
            Picker("", selection: $settings.commentsPreferredOrder) {
                ForEach(CommentsOrder.allCases) { sort in
                    
                    Label {
                        Text(sort.viewString)
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: sort.systemImage)
                            .foregroundColor(sort.color)
                    }
                    .tag(sort.rawValue)
                        
                }
            }
            .pickerStyle(.inline)
            .onChange(of: settings.commentsPreferredOrder) { _ in
                try? moc.save()
            }
        }
        .navigationTitle("Comments order")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}


struct InterfaceSettingsView: View {
    
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var settings: Settings
    
    private func postOrderLabel() -> some View {
        let order = SettingsReader.postsPreferredSort
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
        
        let valueStr = range != nil ? "\(SettingsReader.postsPreferredSort.displayText) (\(range!))" : SettingsReader.postsPreferredSort.displayText
        
        return LabelWithValue("Posts preferred order", value: valueStr)
    }
    
    var body: some View {
        
        Form {
            
            Section("SUBREDDITS") {
                NavigationLink {
                    SubredditPreferredOrderPicker(settings: settings)
                } label: {
                    LabelWithValue("Subreddits preferred order", value: SettingsReader.subredditsPreferredSort.displayText)
                }
            }
            
            Section("POSTS") {
                NavigationLink {
                    PostOrderPicker(selected: $settings.postPreferredSort)
                        .onChange(of: settings.postPreferredSort) { _ in
                            try? moc.save()
                        }
                } label: {
                    postOrderLabel()
                }
                
                HStack{
                    Text("Post view mode")
                    Picker("", selection: $settings.postCardSize) {
                        
                        Text("Compact")
                            .tag(PostCardSize.compact.rawValue)
                        
                        Text("Large")
                            .tag(PostCardSize.large.rawValue)
                        
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: settings.postCardSize) { _ in
                        try? moc.save()
                    }
                }
                
                Toggle("Load new posts automatically", isOn: $settings.automaticLoadNewPosts)
                    .onChange(of: settings.automaticLoadNewPosts) { newValue in
                        try? moc.save()
                    }
            }
            
            Section("COMMENTS") {
                NavigationLink {
                    CommentsPreferredOrderPicker(settings: settings)
                } label: {
                    LabelWithValue("Comments preferred order", value: SettingsReader.commentsPreferredSort.viewString)
                }
            }
            
        }
        .navigationTitle("Interface")
        
        
    }
}
