import SwiftUI

struct EarthquakeListView: View {
    @ObservedObject var data = EarthquakeData()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Set the background color for the entire view
                Color(hex: "091428")
                    .edgesIgnoringSafeArea(.all) // Ensure it ignores the Safe Area
                
                VStack(spacing: 0) {
                    if let errorMessage = data.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else if data.earthquakes.isEmpty {
                        Text("No Earthquake Data Available")
                            .foregroundColor(.gray)
                    } else {
                        // Display last 5 earthquakes
                        VStack(spacing: 8) {
                            ForEach(data.earthquakes.prefix(5), id: \.id) { quake in
                                ZStack {
                                    // Gradient background for each earthquake
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "26397e"),
                                                    Color(hex: "0c98c9")
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(10)
                                        .frame(maxWidth: .infinity) // Fill full width of the screen
                                        .frame(height: 60) // Set height of the rectangle
                                    
                                    // Content inside the rectangle
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            // Time and Intensity (bold and bigger)
                                            Text(formatTime(from: quake.time))
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            // Location
                                            Text(quake.location)
                                                .font(.system(size: 16))
                                                .foregroundColor(.white)
                                                .lineLimit(1) // Prevent overflow, if needed
                                                .truncationMode(.tail) // Add ellipsis if too long
                                            
                                            Spacer()
                                            
                                            Text("Intensity: \(quake.intensity)")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal)
                                        
                                        HStack {
                                            // Date and Magnitude (smaller font)
                                            Text(formatDate(from: quake.time))
                                                .font(.system(size: 12))
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            Text("Magnitude: \(String(format: "%.1f", quake.magnitude))")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    data.fetchEarthquakeData()
                }
                // No need to set background here again since it's covered by ZStack
                .navigationBarHidden(true) // Optional: Hide navigation bar
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Optional: Use for better compatibility on iPads
    }
    
    // Helper function to format time
    func formatTime(from time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        return time
    }
    
    // Helper function to format date
    func formatDate(from time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: date)
        }
        return time
    }
}
