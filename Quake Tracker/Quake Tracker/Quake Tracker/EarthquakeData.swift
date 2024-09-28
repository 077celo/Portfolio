//
//  EarthquakeData.swift
//  Quake Tracker
//
//  Created by Marcelo on 09/09/24.
//

import Foundation

class EarthquakeData: ObservableObject {
    @Published var earthquakes: [Earthquake] = []
    @Published var errorMessage: String? = nil
    
    private let apiService = APIService()
    
    func fetchEarthquakeData() {
        apiService.fetchEarthquakeData { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let earthquakes):
                    self?.earthquakes = earthquakes
                case .failure(let error):
                    self?.errorMessage = "Failed to load data: \(error.localizedDescription)"
                }
            }
        }
    }
}
