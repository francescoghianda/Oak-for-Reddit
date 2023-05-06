//
//  NewCommentForm.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 06/05/23.
//

import SwiftUI

struct NewCommentForm: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var text: String = ""
    @State private var showInReplyTo: Bool = true
    @State private var submitting: Bool = false
    @State private var error: Bool = false
    @Binding var status: NewCommentStatus
    let parentId: String
    let parentComment: Comment?
    private let maxLength = 10_000
    
    init(parentId: String, parentComment: Comment? = nil, status: Binding<NewCommentStatus>) {
        self.parentId = parentId
        self.parentComment = parentComment
        self._status = status
    }
    
    var body: some View {
        
        
        NavigationView {
            
            Form {
                
                if let parentComment = parentComment {
                    
                    Section {
                        if showInReplyTo {
                            CommentCard(comment: parentComment, showContextMenu: false)
                                .disabled(true)
                        }
                    } header: {
                        
                        HStack {
                            Text("In reply to")
                            Spacer()
                            Button {
                                withAnimation {
                                    showInReplyTo.toggle()
                                }
                            } label: {
                                HStack {
                                    Text(showInReplyTo ? "Hide" : "Show")
                                    Image(systemName: "chevron.right")
                                        .rotationEffect(.degrees(showInReplyTo ? 90 : 0))
                                }
                            }
                        }
                        
                    }

                }
                
                Section("Text") {
                    
                    let color: Color = {
                        let fillRate: Float = Float(text.count) / Float(maxLength)
                        if fillRate < 0.5 {
                            return Color.gray
                        }
                        if fillRate < 0.8 {
                            return Color.yellow
                        }
                        
                        return Color.red
                    }()
                    
                    VStack {
                        TextEditor(text: $text)
                            .frame(height: 200)
                        
                        Text("\(text.count) · \(maxLength)")
                            .font(.caption)
                            .foregroundColor(color)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                
                
            }
            .interactiveDismissDisabled()
            .onChange(of: text) { newText in
                if text.count > maxLength {
                    text = String(text.prefix(maxLength))
                }
            }
            .navigationTitle("New comment")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        self.status = .canceled
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        submit()
                    } label: {
                        Label("Submit", systemImage: "paperplane.fill")
                    }
                    .disabled(text.trimmingCharacters(in: [" "]).isEmpty)
                }
                
                
                
            }
            .disabled(submitting)
            .toast(isPresenting: $submitting, autoClose: false) {
                ProgressView()
            }
            .toast(isPresenting: $error) {
                Text("An error occured")
            }
            
        }
        
    }
    
    func submit() {
        submitting = true
        Task(priority: .userInitiated) {
            
            do {
                
                let comment = (try await ApiFetcher.shared.fetch(endpoint: .submitComment(parentFullname: parentId, text: text), parser: Parsers.moreCommentsParser)).comments.first!
                
                Task { @MainActor in
                    self.status = .submitted(comment: comment)
                    self.submitting = false
                    
                    withAnimation {
                        dismiss()
                    }
                }
                
            }
            catch {
                
                print("Error submitting comment: ", error)
                
                Task { @MainActor in
                    self.submitting = false
                    self.error = true
                }
            }
            
        }
        
        
        
    }
}

struct NewCommentForm_Previews: PreviewProvider {
    
    static let parent = CommentsPreviewData.comment
    static let post = PostsPreviewData.post
    
    static var previews: some View {
        VStack {
            
        }
        .sheet(isPresented: Binding.constant(true)) {
            NewCommentForm(parentId: parent.name, parentComment: parent, status: Binding.constant(.canceled))
        }
        .environmentObject(post)
        //.previewDevice("iPhone 12")
    }
}
