//
//  WeatherService.swift
//  TempConverter
//

import Foundation
import Observation

@MainActor
@Observable
class WeatherService {
    var isLoading = false

    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8
        session = URLSession(configuration: config)
    }

    func fetchTemperature(inFahrenheit: Bool) async throws -> Double {
        isLoading = true
        defer { isLoading = false }

        let (lat, lon) = try await fetchLocation()
        return try await fetchWeather(lat: lat, lon: lon, inFahrenheit: inFahrenheit)
    }

    // Uses IP-based geolocation — no permission required, city-level accuracy
    private func fetchLocation() async throws -> (Double, Double) {
        let (data, _) = try await session.data(from: URL(string: "https://ipwho.is/")!)

        struct IPLocation: Decodable {
            let success: Bool
            let latitude: Double
            let longitude: Double
        }

        let result = try JSONDecoder().decode(IPLocation.self, from: data)
        guard result.success else {
            throw CocoaError(.featureUnsupported, userInfo: [NSLocalizedDescriptionKey: "Could not determine location."])
        }
        return (result.latitude, result.longitude)
    }

    private func fetchWeather(lat: Double, lon: Double, inFahrenheit: Bool) async throws -> Double {
        let unit = inFahrenheit ? "fahrenheit" : "celsius"
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m&temperature_unit=\(unit)")!

        let (data, _) = try await session.data(from: url)

        struct Response: Decodable {
            struct Current: Decodable {
                let temperature2m: Double
                enum CodingKeys: String, CodingKey { case temperature2m = "temperature_2m" }
            }
            let current: Current
        }

        let response = try JSONDecoder().decode(Response.self, from: data)
        return response.current.temperature2m
    }
}
