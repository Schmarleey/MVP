import SwiftUI

struct TintedGlassButton: View {
    var systemImage: String
    
    var body: some View {
        ZStack {
            // Glassmorpher Hintergrund mit eingefärbtem Blur (Farbcode #F7B32B → RGB: 247, 179, 43)
            Capsule()
                .fill(.ultraThinMaterial)
                .background(
                    Capsule()
                        .fill(Color(red: 247/255, green: 179/255, blue: 43/255).opacity(0.2))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
            Image(systemName: systemImage)
                .font(.system(size: 24))
                .foregroundColor(.primary)
        }
        .frame(width: 50, height: 50)
    }
}

struct TintedGlassButton_Previews: PreviewProvider {
    static var previews: some View {
        TintedGlassButton(systemImage: "camera.circle.fill")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
