import Foundation
import FoundationModels

struct GetWeatherTool: Tool {
    let name = "getWeather"
    let description = "Retrieve the latest weather forecast for a city. ONLY use this tool when the user asks about the weather."
    
    @Generable
    struct Arguments {
        @Guide(description: "The city to fetch the weather for")
        var city: String
    }
    
    func call(arguments: Arguments) async throws -> some PromptRepresentable {
        return "The weather in \(arguments.city) is 22°C and sunny."
    }
}
