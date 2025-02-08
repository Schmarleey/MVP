import SwiftUI

struct FeedView: View {
    @State private var posts: [SocialPost] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredPosts) { post in
                            SocialPostView(post: post, isCurrentUser: (post.userId == appState.userId))
                        }
                    }
                    .padding()
                }
                .navigationBarHidden(true)
                .onAppear(perform: loadPosts)
                .alert(isPresented: .constant(!errorMessage.isEmpty)) {
                    Alert(title: Text("Fehler"),
                          message: Text(errorMessage),
                          dismissButton: .default(Text("OK")))
                }
                
                // Floating Search Bar: Oben rechts
                VStack {
                    HStack {
                        Spacer()
                        FloatingSearchBar(searchText: $searchText, isSearchActive: $isSearchActive)
                            .padding(.top, 10)
                            .padding(.trailing, 20)
                    }
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $appState.showNewPost) {
            NewPostView(initialSourceType: .camera)
                .environmentObject(appState)
        }
    }
    
    var filteredPosts: [SocialPost] {
        if searchText.isEmpty {
            return posts
        } else {
            return posts.filter { post in
                (post.username?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (post.message?.lowercased().contains(searchText.lowercased()) ?? false)
            }
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
