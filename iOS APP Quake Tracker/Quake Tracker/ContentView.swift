//
//  ContentView.swift
//  Quake Tracker
//
//  Created by Marcelo on 09/09/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(hex: "091428") // Background color for the entire screen
                .edgesIgnoringSafeArea(.all) // Ensure it covers the safe area
            
            VStack(spacing: 0) {
                HeaderView()
                    .frame(height: 40)
                MapViewContainer()
                    .frame(height: 350)
                    .cornerRadius(10)
                    .padding(.top, 20)
                EarthquakeListView()
            }
        }
    }
}


extension Color {
        init(hex: String) {
            var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            if hexFormatted.hasPrefix("#") {
                hexFormatted.remove(at: hexFormatted.startIndex)
            }
            var rgb: UInt64 = 0
            Scanner(string: hexFormatted).scanHexInt64(&rgb)
            
            let red = Double((rgb >> 16) & 0xFF) / 255.0
            let green = Double((rgb >> 8) & 0xFF) / 255.0
            let blue = Double(rgb & 0xFF) / 255.0
            
            self.init(red: red, green: green, blue: blue)
            
        }
    }

