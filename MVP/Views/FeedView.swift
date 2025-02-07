import SwiftUI

struct FeedView: View {
    @State private var posts: [SocialPost] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(posts) { post in
                            SocialPostView(post: post, isCurrentUser: (post.userId == appState.userId))
                        }
                    }
                    .padding()
                }
                .navigationTitle("Social Feed")
                .onAppear(perform: loadPosts)
                .alert(isPresented: .constant(!errorMessage.isEmpty)) {
                    Alert(title: Text("Fehler"),
                          message: Text(errorMessage),
                          dismissButton: .default(Text("OK")))
                }
                
                // Overlay: Floating Create-Button (links oben) – Positionierung anpassen, sodass er direkt über der Tabbar liegt
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: {
                                appState.showNewPost = true
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }) {
                                TintedGlassButton(systemImage: "camera.circle.fill")
                            }
                            .padding(.leading, 20)
                            .padding(.bottom, 130)
                            Spacer()
                        }
                        .frame(width: geometry.size.width, alignment: .bottomLeading)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $appState.showNewPost) {
            NewPostView(initialSourceType: .camera)
                .environmentObject(appState)
        }
    }
    
    func loadPosts() {
        isLoading = true
        FeedService.shared.fetchSocialPosts { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let posts):
                    self.posts = posts
                    print("FeedView: \(posts.count) SocialPosts geladen")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("FeedView: Fehler: \(error.localizedDescription)")
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
