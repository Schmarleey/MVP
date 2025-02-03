//
//  TagCloudView.swift
//  MVP
//
//  Created by Marlon Becker on 03.02.25.
//

/// Views/TagCloudView.swift
import SwiftUI

struct TagCloudView: View {
    let tags: [String]
    let spacing: CGFloat
    let onTap: (String) -> Void
    let isSelected: (String) -> Bool
    
    var body: some View {
        GeometryReader { geometry in
            let rows = splitTags(availableWidth: geometry.size.width)
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(0..<rows.count, id: \.self) { rowIndex in
                    HStack(spacing: spacing) {
                        ForEach(rows[rowIndex], id: \.self) { tag in
                            InterestOptionView(interest: tag, isSelected: isSelected(tag))
                                .onTapGesture { onTap(tag) }
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, alignment: .leading)
        }
        .frame(minHeight: 0)
    }
    
    private func splitTags(availableWidth: CGFloat) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentWidth: CGFloat = 0
        let font = UIFont.systemFont(ofSize: 16)
        
        for tag in tags {
            let tagWidth = tag.size(withAttributes: [.font: font]).width + 32 // geschätzter Puffer
            if currentWidth + tagWidth + spacing > availableWidth {
                rows.append(currentRow)
                currentRow = [tag]
                currentWidth = tagWidth
            } else {
                currentRow.append(tag)
                currentWidth += tagWidth + spacing
            }
        }
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        return rows
    }
}

struct TagCloudView_Previews: PreviewProvider {
    static var previews: some View {
        TagCloudView(tags: ["Abenteuer", "Kulinarik", "Kultur", "Sport", "Musik", "Party", "Outdoor"], spacing: 8, onTap: { _ in }, isSelected: { _ in false })
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
