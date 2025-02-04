// Views/CommentRowView.swift
import SwiftUI

struct CommentRowView: View {
    let comment: Comment
    @State private var likeCount: Int = 0
    @State private var isLiking: Bool = false
    @State private var showReplyField: Bool = false
    @State private var replyText: String = ""
    @State private var replies: [Comment] = []
    @State private var isLoadingReplies: Bool = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                // Profilbild des Kommentators
                if let profileUrl = getProfileImageUrl(for: comment.userId),
                   let url = URL(string: profileUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color.gray)
                    }
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                } else {
                    Circle().fill(Color.gray).frame(width: 30, height: 30)
                }
                VStack(alignment: .leading) {
                    Text(getUsername(for: comment.userId) ?? "Unbekannt")
                        .font(.caption)
                        .bold()
                    Text(comment.comment)
                        .font(.body)
                    Text(timeAgo(comment.createdAt))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack {
                    Button(action: {
                        likeComment()
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                    }
                    Text("\(likeCount)")
                        .font(.caption)
                    Button(action: {
                        showReplyField.toggle()
                    }) {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .font(.title2)
                    }
                }
            }
            if showReplyField {
                HStack {
                    TextField("Antworten...", text: $replyText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        addReply()
                    }) {
                        Text("Senden")
                    }
                }
                .padding(.leading, 40)
            }
            // Verschachtelte Antworten
            if !replies.isEmpty {
                ForEach(replies) { reply in
                    CommentRowView(comment: reply)
                        .padding(.leading, 40)
                        .environmentObject(appState)
                }
            }
        }
        .onAppear {
            fetchLikeCount()
            fetchReplies()
        }
    }
    
    func likeComment() {
        guard let userId = appState.userId else { return }
        isLiking = true
        LikesService.shared.likeComment(commentId: comment.id, userId: userId) { result in
            DispatchQueue.main.async {
                isLiking = false
                switch result {
                case .success():
                    fetchLikeCount()
                case .failure(let error):
                    print("Fehler beim Liken des Kommentars: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchLikeCount() {
        LikesService.shared.fetchCommentLikes(commentId: comment.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let count):
                    likeCount = count
                case .failure(let error):
                    print("Fehler beim Laden der Comment Likes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchReplies() {
        isLoadingReplies = true
        CommentsService.shared.fetchReplies(parentCommentId: comment.id) { result in
            DispatchQueue.main.async {
                isLoadingReplies = false
                switch result {
                case .success(let fetchedReplies):
                    replies = fetchedReplies
                case .failure(let error):
                    print("Fehler beim Laden der Replies: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addReply() {
        guard !replyText.trimmingCharacters(in: .whitespaces).isEmpty,
              let userId = appState.userId else { return }
        let reply = Comment(id: UUID().uuidString, postId: comment.postId, userId: userId, comment: replyText, createdAt: Date(), parentCommentId: comment.id)
        CommentsService.shared.createComment(comment: reply) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newReply):
                    replies.append(newReply)
                    replyText = ""
                case .failure(let error):
                    print("Fehler beim Hinzufügen der Antwort: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Dummy-Helferfunktionen – bitte im echten Projekt durch echte Daten ersetzen.
    func getProfileImageUrl(for userId: String) -> String? {
        // Beispiel: Hier könnte ein Service abgefragt werden, der das Profilbild für den User liefert.
        return "https://syehmjmotifoiisawceb.supabase.co/storage/v1/object/public/profile-images/dummy.jpg"
    }
    
    func getUsername(for userId: String) -> String? {
        return "Benutzer"
    }
    
    func timeAgo(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct CommentRowView_Previews: PreviewProvider {
    static var previews: some View {
        CommentRowView(comment: Comment(id: UUID().uuidString, postId: UUID().uuidString, userId: "123", comment: "Testkommentar", createdAt: Date(), parentCommentId: nil))
            .environmentObject(AppState())
    }
}
