import SwiftUI

class ImageCacheManager {
    static let shared = NSCache<NSURL, UIImage>()
}

struct CachedAsyncImage: View {
    let url: URL
    @State private var loadedImage: Image? = nil
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            if let image = loadedImage {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
            } else if isLoading {
                ProgressView()
            } else {
                Color.gray
                    .onAppear { loadImage() }
            }
        }
    }
    
    func loadImage() {
        guard !isLoading else { return }
        isLoading = true
        
        if let cached = ImageCacheManager.shared.object(forKey: url as NSURL) {
            loadedImage = Image(uiImage: cached)
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            isLoading = false
            if let data = data, let uiImage = UIImage(data: data) {
                ImageCacheManager.shared.setObject(uiImage, forKey: url as NSURL)
                DispatchQueue.main.async {
                    withAnimation {
                        loadedImage = Image(uiImage: uiImage)
                    }
                }
            }
        }.resume()
    }
}

struct CachedAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        CachedAsyncImage(url: URL(string: "https://via.placeholder.com/300")!)
            .frame(width: 300, height: 200)
    }
}
