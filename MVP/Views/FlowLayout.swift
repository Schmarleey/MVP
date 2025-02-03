// Views/FlowLayout.swift
import SwiftUI

/// Ein einfacher Flow-Container, der Elemente nebeneinander anordnet und automatisch umbricht.
struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    init(items: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    func generateContent(in geometry: GeometryProxy) -> some View {
        var rows: [[Data.Element]] = [[]]
        var currentRowWidth: CGFloat = 0
        
        // Schätze die Breite jedes Elements mithilfe eines approximativen Mindestwertes.
        // Dies ist ein einfacher Ansatz, der für viele Anwendungsfälle ausreichend sein kann.
        for item in items {
            let estimatedWidth: CGFloat = 80 + spacing
            if currentRowWidth + estimatedWidth > geometry.size.width {
                rows.append([item])
                currentRowWidth = estimatedWidth
            } else {
                rows[rows.count - 1].append(item)
                currentRowWidth += estimatedWidth
            }
        }
        
        return VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(rows[rowIndex], id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }
}

struct FlowLayout_Previews: PreviewProvider {
    static var previews: some View {
        FlowLayout(items: ["Abenteuer", "Kulinarik", "Kultur", "Sport", "Musik"]) { interest in
            InterestOptionView(interest: interest, isSelected: Bool.random())
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
