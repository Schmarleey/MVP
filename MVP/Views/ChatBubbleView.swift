// Views/ChatBubbleView.swift
import SwiftUI

struct ChatBubbleView: View {
    let post: Post
    let isCurrentUser: Bool
    @EnvironmentObject var appState: AppState
    @State private var reactionCount: Int = 0
    @State private var postLikeCount: Int = 0
    @State private var showComments = false
    
    var body: some View {
        HStack {
            if !isCurrentUser {
                cardView
                Spacer(minLength: 50)
            } else {
                Spacer(minLength: 50)
                cardView
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .sheet(isPresented: $showComments) {
            NavigationView {
                CommentsView(post: post)
                    .environmentObject(appState)
            }
        }
    }
    
    private var cardView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Kopfzeile: Profilbild und Username
            HStack(alignment: .center, spacing: 8) {
                profileImageView
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(postUsername())
                        .font(.subheadline)
                        .bold()
                    Text(timeAgo(post.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            
            Divider()
            
            // Inhalt: Medien (1:1 Format) und Nachricht
            VStack(alignment: .leading, spacing: 8) {
                if let mediaUrl = post.mediaUrl, let url = URL(string: mediaUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                             .aspectRatio(1, contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(8)
                }
                if let message = post.message, !message.isEmpty {
                    Text(message)
                        .font(.body)
                        .padding(8)
                        .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(isCurrentUser ? .white : .black)
                        .cornerRadius(8)
                }
            }
            
            // Top-Kommentar als Vorschau (falls vorhanden)
            if let topComment = fetchTopComment(for: post) {
                HStack {
                    Text("„\(topComment.comment)“")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            // Fußzeile: Like-Button, Like-Anzahl und Kommentar-Button
            HStack {
                Button(action: {
                    likePost()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                        Text("\(postLikeCount)")
                            .font(.caption)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: {
                    showComments = true
                }) {
                    Image(systemName: "bubble.right.fill")
                        .font(.title2)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
        .onAppear {
            fetchPostLikeCount()
        }
    }
    
    private var profileImageView: some View {
        Group {
            // Verwende das Profilbild aus dem Post (das sollte vom Backend kommen)
            if let profileUrl = post.profileImage, let url = URL(string: profileUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color.gray)
                }
                .clipShape(Circle())
            } else {
                Circle().fill(Color.gray)
            }
        }
    }
    
    private func postUsername() -> String {
        if isCurrentUser {
            return "Du"
        } else {
            return post.username ?? "Freund"
        }
    }
    
    private func timeAgo(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func likePost() {
        guard let userId = appState.userId else { return }
        LikesService.shared.likePost(postId: post.id, userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    fetchPostLikeCount()
                case .failure(let error):
                    print("Fehler beim Liken des Posts: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchPostLikeCount() {
        LikesService.shared.fetchPostLikes(postId: post.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let count):
                    postLikeCount = count
                case .failure(let error):
                    print("Fehler beim Laden der Post Likes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Dummy-Methode: Top-Kommentar ermitteln (in einem echten Projekt würde dies über den Backend-Query erfolgen)
    private func fetchTopComment(for post: Post) -> Comment? {
        // Hier könnte man z. B. den ersten Kommentar (nach created_at) zurückgeben
        // Für dieses Beispiel wird nil zurückgegeben – implementiere die Logik nach Bedarf.
        return nil
    }
}

struct ChatBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            ChatBubbleView(
                post: Post(
                    id: UUID().uuidString,
                    userId: "123",
                    mediaUrl: "https://via.placeholder.com/300", // Platzhalterbild (1:1)
                    message: "Hallo, wie geht's?",
                    createdAt: Date().addingTimeInterval(-3600),
                    profileImage: "https://syehmjmotifoiisawceb.supabase.co/storage/v1/object/public/profile-images/5A8FDDF0-0BCE-4915-98AA-60270BE64D4B.jpg",
                    username: "Alice"
                ),
                isCurrentUser: false
            )
            ChatBubbleView(
                post: Post(
                    id: UUID().uuidString,
                    userId: "456",
                    mediaUrl: "https://via.placeholder.com/300",
                    message: "Mir geht's gut, danke!",
                    createdAt: Date().addingTimeInterval(-1800),
                    profileImage: nil,
                    username: "Bob"
                ),
                isCurrentUser: true
            )
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .environmentObject(AppState())
    }
}
