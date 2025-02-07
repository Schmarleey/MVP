// Views/SocialPostView.swift
import SwiftUI

struct SocialPostView: View {
    let post: SocialPost
    let isCurrentUser: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Profilbild und Username
            HStack(spacing: 8) {
                if let profileUrl = post.profileImage, let url = URL(string: profileUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure(_):
                            Circle().fill(Color.gray)
                        @unknown default:
                            Circle().fill(Color.gray)
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Circle().fill(Color.gray).frame(width: 40, height: 40)
                }
                Text(post.username ?? (isCurrentUser ? "Du" : "Unbekannt"))
                    .font(.subheadline)
                    .bold()
                Spacer()
            }
            
            // Bild (falls vorhanden)
            if let mediaUrl = post.mediaUrl, let url = URL(string: mediaUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable().aspectRatio(1, contentMode: .fill)
                    case .failure(_):
                        Color.gray
                    @unknown default:
                        Color.gray
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()
                .cornerRadius(8)
            }
            
            // Nachricht (falls vorhanden)
            if let message = post.message, !message.isEmpty {
                Text(message)
                    .font(.body)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

struct SocialPostView_Previews: PreviewProvider {
    static var previews: some View {
        SocialPostView(
            post: SocialPost(
                id: UUID().uuidString,
                userId: "123",
                mediaUrl: "https://via.placeholder.com/300",
                message: "Hallo, wie geht's?",
                createdAt: Date().addingTimeInterval(-3600),
                username: "Alice",
                profileImage: "https://syehmjmotifoiisawceb.supabase.co/storage/v1/object/public/profile-images/your-profile.jpg"
            ),
            isCurrentUser: false
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
