// Views/FeedView.swift
import SwiftUI

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingNewPost = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                        .padding()
                }
                ScrollView {
                    VStack(spacing: 8) {
                        // Sortiere Beiträge chronologisch
                        ForEach(posts.sorted { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) }) { post in
                            ChatBubbleView(post: post, isCurrentUser: (post.userId == appState.userId))
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Social Feed")
            .navigationBarItems(trailing: Button(action: {
                print("Kamera-Button gedrückt")
                showingNewPost = true
            }) {
                Image(systemName: "camera.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
            })
            .onAppear { loadPosts() }
        }
        // Hänge das Sheet an den NavigationView an
        .sheet(isPresented: $showingNewPost) {
            NewPostView(initialSourceType: .camera)
                .environmentObject(appState)
        }
        // Sicherstellen, dass der NavigationView den gesamten Raum einnimmt
        .edgesIgnoringSafeArea(.all)
    }
    
    func loadPosts() {
        isLoading = true
        FeedService.shared.fetchPosts { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let posts):
                    self.posts = posts
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView().environmentObject(AppState())
    }
}
