import SwiftUI
import MapKit
import Combine

// MARK: - Models

struct Earthquake: Codable, Identifiable {
    var id: String { eid }
    let eid: String
    let anm: String
    let mag: String
    let maxi: String
    let rdt: String
    let cod: String
}

struct City: Codable {
    let code: String
    let maxi: String
}

struct Prefecture: Codable {
    let code: String
    let maxi: String
    let city: [City]
}

// MARK: - ViewModel

class EarthquakeViewModel: ObservableObject {
    @Published var earthquakes: [Earthquake] = []
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.0, longitude: 135.0), span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0))

    private var cancellables = Set<AnyCancellable>()
    private let apiUrl = "https://www.jma.go.jp/bosai/quake/data/list.json"

    func fetchEarthquakes() {
        guard let url = URL(string: apiUrl) else { return }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Earthquake].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching data: \(error)")
                }
            }, receiveValue: { [weak self] fetchedEarthquakes in
                // Sort by report date, showing most recent earthquakes first
                let sortedEarthquakes = fetchedEarthquakes.sorted(by: { $0.rdt > $1.rdt })
                // Limit to the last 20 earthquakes
                self?.earthquakes = Array(sortedEarthquakes.prefix(20))
                print("Fetched earthquakes: \(self?.earthquakes.count ?? 0)") // Debugging
            })
            .store(in: &cancellables)
    }
}

// MARK: - EarthquakeListView

struct EarthquakeListView: View {
    @StateObject var viewModel = EarthquakeViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Earthquake List
                List(viewModel.earthquakes) { earthquake in
                    VStack(alignment: .leading) {
                        Text("Location: \(earthquake.anm)")
                            .font(.headline)
                        Text("Magnitude: \(earthquake.mag) | Intensity: \(earthquake.maxi)")
                        Text("Reported on: \(earthquake.rdt)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onAppear {
                viewModel.fetchEarthquakes()
            }
            .navigationBarTitle("Recent Earthquakes")
        }
    }

    // Helper function to extract coordinates from earthquake data
    func getLatitude(from cod: String) -> Double? {
        let components = cod.split(separator: "+").map { Double($0) }
        if components.count >= 2 {
            return components[1]
        } else {
            print("Failed to get latitude from cod: \(cod)") // Debugging
            return nil
        }
    }

    func getLongitude(from cod: String) -> Double? {
        let components = cod.split(separator: "+").map { Double($0) }
        if components.count >= 3 {
            return components[2]
        } else {
            print("Failed to get longitude from cod: \(cod)") // Debugging
            return nil
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    var body: some View {
        EarthquakeListView()
    }
}

// MARK: - Preview

@main
struct EarthquakeTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
