import SwiftUI

struct TimelineEventRow: View {
    let event: Event
    let showMonthMarker: Bool
    let monthText: String?  // z. B. "März 2025"

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Timeline-Spalte
            VStack(alignment: .center) {
                if showMonthMarker, let monthText = monthText {
                    // Monatsmarker: ein größerer Kreis mit der Monatsüberschrift daneben (oder darüber)
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 14, height: 14)
                        Text(monthText)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 4)
                } else {
                    // Sonst: kleiner Punkt (Dot) – immer zentriert in der Zeile
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .padding(.bottom, 10)
                }
                // Verlängerung des Zeitstrahls (flexible Linie, die nach unten reicht)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 50)  // Feste Breite für die Timeline-Spalte

            // Event-Karte
            VStack(alignment: .leading, spacing: 8) {
                if let imageUrl = event.eventImage, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(maxWidth: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: UIScreen.main.bounds.width - 80) // Dynamische Breite, sodass es quadratisch ist
                                .clipped()
                        case .failure(_):
                            Color.gray.frame(maxWidth: .infinity)
                                .frame(height: UIScreen.main.bounds.width - 80)
                        @unknown default:
                            Color.gray.frame(maxWidth: .infinity)
                                .frame(height: UIScreen.main.bounds.width - 80)
                        }
                    }
                    .cornerRadius(8)
                } else {
                    Color.gray
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.width - 80)
                        .cornerRadius(8)
                }
                Text(event.title)
                    .font(.headline)
                if let description = event.description {
                    Text(description)
                        .font(.body)
                        .lineLimit(2)
                }
                if let location = event.location {
                    Text(location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let eventDate = event.eventDate {
                    Text(eventDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct TimelineEventRow_Previews: PreviewProvider {
    static var previews: some View {
        TimelineEventRow(
            event: Event(
                id: UUID().uuidString,
                creatorId: "dummy",
                title: "Sample Event",
                description: "Dies ist ein Beispiel-Event.",
                location: "Berlin",
                eventDate: Date(),
                price: 9.99,
                ticketInfo: nil,
                eventImage: "https://via.placeholder.com/300",
                createdAt: Date()
            ),
            showMonthMarker: true,
            monthText: "März 2025"
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
