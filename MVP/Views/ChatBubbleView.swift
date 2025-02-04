// Views/ChatBubbleView.swift
import SwiftUI

struct ChatBubbleView: View {
    let post: Post
    let isCurrentUser: Bool
    @EnvironmentObject var appState: AppState  // Zugriff auf den globalen Zustand

    @State private var reactionCount: Int = 0

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
    }
    
    /// Die Karte, die alle Inhalte eines Beitrags zusammenfasst.
    private var cardView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Kopfzeile: Profilbild, tatsächlicher Username und Zeitstempel
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
            
            // Inhalt: Medienbild (falls vorhanden) und Nachricht
            VStack(alignment: .leading, spacing: 8) {
                if let mediaUrl = post.mediaUrl, let url = URL(string: mediaUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
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
            
            // Fußzeile: Like-Button
            HStack {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    reactionCount += 1
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("\(reactionCount)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
    
    /// Zeigt das Profilbild an.
    private var profileImageView: some View {
        Group {
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
    
    /// Gibt den tatsächlichen Username zurück:
    private func postUsername() -> String {
        if isCurrentUser {
            // Für eigene Beiträge: Verwende den aktuellen Username aus dem AppState.
            return appState.currentUsername ?? "Du"
        } else {
            // Für fremde Beiträge: Verwende den Username aus dem Post oder einen Standardwert.
            return post.username ?? "Freund"
        }
    }
    
    /// Formatiert den Zeitstempel relativ zur aktuellen Zeit.
    private func timeAgo(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ChatBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            ChatBubbleView(
                post: Post(
                    id: UUID().uuidString,
                    userId: "123",
                    mediaUrl: nil,
                    message: "Hallo, wie geht's?",
                    createdAt: Date().addingTimeInterval(-3600),
                    profileImage: "https://example.com/profile1.jpg",
                    username: "Alice"
                ),
                isCurrentUser: false
            )
            ChatBubbleView(
                post: Post(
                    id: UUID().uuidString,
                    userId: "456",
                    mediaUrl: nil,
                    message: "Mir geht's gut, danke!",
                    createdAt: Date().addingTimeInterval(-1800),
                    profileImage: "https://example.com/profile2.jpg",
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
