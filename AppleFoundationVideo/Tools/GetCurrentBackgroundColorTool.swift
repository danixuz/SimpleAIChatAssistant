import SwiftUI
import FoundationModels

struct GetCurrentBackgroundColorTool: Tool {
    let name = "getCurrentBackgroundColor"
    let description = "Retrieves the current background color of the chat view."
    
    @Generable
    struct Arguments {}
    
    let onGetColor: @MainActor () -> String
    
    func call(arguments: Arguments) async throws -> some PromptRepresentable {
        let color = await onGetColor()
        return "The current chat background color is \(color)."
    }
}
