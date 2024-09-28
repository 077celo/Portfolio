//
//  APIService.swift
//  Quake Tracker
//

import Foundation

class APIService {
    let earthquakeURL = "https://www.jma.go.jp/bosai/quake/data/list.json"
    
    func fetchEarthquakeData(completion: @escaping (Result<[Earthquake], Error>) -> Void) {
        guard let url = URL(string: earthquakeURL) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let quakeData = try decoder.decode([JmaQuakeData].self, from: data)
                
                let earthquakes = quakeData.compactMap { quake -> Earthquake? in
                    if let earthquake = Earthquake(from: quake) {
                        return earthquake
                    } else {
                        print("Failed to parse earthquake data for \(quake)")
                        return nil
                    }
                }
                completion(.success(earthquakes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Earthquake Model
struct Earthquake: Identifiable {
    var id = UUID()
    var time: String
    var location: String
    var intensity: String
    var latitude: Double
    var longitude: Double
    var depth: Double
    var magnitude: Double
    
    // Helper initializer to handle data parsing
    init?(from data: JmaQuakeData) {
        guard let (latitude, longitude) = Earthquake.parseCoordinates(from: data.cod),
              let magnitude = Double(data.mag) else {
            return nil
        }
        
        self.time = data.at
        self.location = data.anm
        self.intensity = data.int.first?.maxi ?? "N/A"
        self.latitude = latitude
        self.longitude = longitude
        self.depth = Earthquake.parseDepth(from: data.cod) ?? 0.0
        self.magnitude = magnitude
    }
    
    // Helper to parse latitude and longitude
    static func parseCoordinates(from cod: String) -> (Double, Double)? {
        // Handle cases where cod has format like "+26.0+143.2-10000/"
        let components = cod.split(separator: "/").first?.split(separator: "+")
        guard let latitudeString = components?.dropFirst().first,
              let longitudeString = components?.dropFirst(2).first,
              let latitude = Double(latitudeString),
              let longitude = Double(longitudeString) else {
            return nil
        }
        return (latitude, longitude)
    }
    
    // Helper to parse depth
    static func parseDepth(from cod: String) -> Double? {
        guard let depthComponent = cod.split(separator: "-").last,
              let depth = Double(depthComponent) else {
            return nil
        }
        return depth
    }
}

// MARK: - JMA Data Model
struct JmaQuakeData: Codable {
    let at: String
    let anm: String
    let cod: String
    let mag: String
    let int: [Intensity]
    
    struct Intensity: Codable {
        let maxi: String
    }
}
