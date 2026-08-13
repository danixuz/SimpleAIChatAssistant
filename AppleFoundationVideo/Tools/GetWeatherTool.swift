import Foundation
import FoundationModels

struct GetWeatherTool: Tool {
    let name = "getWeather"
    let description = "Retrieve the current live weather and temperature for any city. ONLY use this tool when the user asks about the weather."
    
    @Generable
    struct Arguments {
        @Guide(description: "The city name to fetch current weather for (e.g. Tokyo, London, New York, Paris)")
        var city: String
    }
    
    func call(arguments: Arguments) async throws -> some PromptRepresentable {
        guard let location = try await geocode(city: arguments.city) else {
            return "Could not find location coordinates for \(arguments.city)."
        }
        
        let weather = try await fetchWeather(lat: location.latitude, lon: location.longitude)
        let condition = weatherDescription(for: weather.current.weather_code)
        
        return "Current weather in \(location.name), \(location.country ?? ""): \(condition), \(weather.current.temperature_2m)°C, Wind: \(weather.current.wind_speed_10m) km/h, Humidity: \(weather.current.relative_humidity_2m)%."
    }
    
    // MARK: - Networking Helpers
    private func geocode(city: String) async throws -> LocationResult? {
        guard let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=1&language=en&format=json") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return decoded.results?.first
    }
    
    private func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
    
    private func weatherDescription(for code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1, 2, 3: return "Partly cloudy"
        case 45, 48: return "Foggy"
        case 51, 53, 55: return "Drizzle"
        case 61, 63, 65: return "Rainy"
        case 71, 73, 75: return "Snowy"
        case 80, 81, 82: return "Rain showers"
        case 95, 96, 99: return "Thunderstorm"
        default: return "Partly cloudy"
        }
    }
}

// MARK: - Decodable Models
private struct GeocodingResponse: Codable {
    let results: [LocationResult]?
}

private struct LocationResult: Codable {
    let name: String
    let country: String?
    let latitude: Double
    let longitude: Double
}

private struct WeatherResponse: Codable {
    let current: CurrentWeather
}

private struct CurrentWeather: Codable {
    let temperature_2m: Double
    let relative_humidity_2m: Int
    let weather_code: Int
    let wind_speed_10m: Double
}
