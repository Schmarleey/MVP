import SwiftUI

struct TimelineEventRow: View {
    let event: Event
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        EventCardView(event: event)
            .onTapGesture {
                appState.selectedEvent = event
                appState.showNewPost = true
            }
            .padding(.vertical, 8)
    }
}

struct EventCardView: View {
    let event: Event
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let imageUrl = event.eventImage,
                   !imageUrl.isEmpty,
                   let url = URL(string: imageUrl) {
                    CachedAsyncImage(url: url)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .clipped()
                } else {
                    Color.gray
                        .frame(maxWidth: .infinity, maxHeight: 200)
                }
                if let eventDate = event.eventDate {
                    CalendarIconView(date: eventDate)
                        .padding(6)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
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
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .frame(maxWidth: UIScreen.main.bounds.width - 16)
    }
}

struct CalendarIconView: View {
    let date: Date
    var body: some View {
        VStack(spacing: 0) {
            Text(getMonthString(date))
                .font(.caption2)
                .foregroundColor(.white)
                .frame(width: 28)
                .padding(2)
                .background(Color.red)
            Text(getDayString(date))
                .font(.headline)
                .foregroundColor(.black)
                .frame(width: 28)
                .padding(2)
                .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(radius: 2)
    }
    
    private func getMonthString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
    
    private func getDayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct TimelineEventRow_Previews: PreviewProvider {
    static var previews: some View {
        TimelineEventRow(
            event: Event(
                id: UUID().uuidString,
                creatorId: UUID().uuidString,
                title: "Beispiel-Event",
                description: "Dies ist ein Beispiel-Event.",
                location: "Berlin",
                eventDate: Date(),
                price: 9.99,
                ticketInfo: nil,
                eventImage: "https://via.placeholder.com/300",
                createdAt: Date()
            )
        )
        .environmentObject(AppState())
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
