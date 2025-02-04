// Views/CommentsView.swift
import SwiftUI

struct CommentsView: View {
    let post: Post
    @State private var comments: [Comment] = []
    @State private var newCommentText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView().padding()
            }
            List {
                ForEach(comments) { comment in
                    CommentRowView(comment: comment)
                        .environmentObject(appState)
                }
            }
            HStack {
                TextField("Kommentar schreiben...", text: $newCommentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    addComment()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                }
            }
            .padding()
        }
        .navigationTitle("Kommentare")
        .onAppear(perform: loadComments)
        .alert(isPresented: .constant(!errorMessage.isEmpty)) {
            Alert(title: Text("Fehler"),
                  message: Text(errorMessage),
                  dismissButton: .default(Text("OK"), action: { errorMessage = "" }))
        }
    }
    
    func loadComments() {
        guard !post.id.isEmpty else { return }
        isLoading = true
        CommentsService.shared.fetchComments(postId: post.id) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedComments):
                    comments = fetchedComments
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func addComment() {
        guard !newCommentText.trimmingCharacters(in: .whitespaces).isEmpty,
              let userId = appState.userId else { return }
        isLoading = true
        let comment = Comment(id: UUID().uuidString, postId: post.id, userId: userId, comment: newCommentText, createdAt: Date(), parentCommentId: nil)
        CommentsService.shared.createComment(comment: comment) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let newComment):
                    comments.append(newComment)
                    newCommentText = ""
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        // Dummy Post für die Vorschau
        CommentsView(post: Post(id: UUID().uuidString, userId: "dummy", mediaUrl: nil, message: "Testpost", createdAt: Date(), profileImage: nil, username: "Test"))
            .environmentObject(AppState())
    }
}
