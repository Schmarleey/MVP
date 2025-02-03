//
//  Intereset.swift
//  MVP
//
//  Created by Marlon Becker on 03.02.25.
//

// Views/InterestOptionView.swift
import SwiftUI

struct InterestOptionView: View {
    let interest: String
    let isSelected: Bool

    var body: some View {
        Text(interest)
            .padding(8)
            .background(isSelected ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(8)
    }
}

struct InterestOptionView_Previews: PreviewProvider {
    static var previews: some View {
        InterestOptionView(interest: "Abenteuer", isSelected: true)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
