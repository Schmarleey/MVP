//
//  HomeView.swift
//  MVP
//
//  Created by Marlon Becker on 03.02.25.
//

// Views/HomeView.swift
import SwiftUI

struct HomeView: View {
    var body: some View {
        Text("Willkommen in der App!")
            .font(.title)
            .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
