import SwiftUI
import FoundationModels

struct ChangeBackgroundColorTool: Tool {
    let name = "changeBackgroundColor"
    let description = "Changes the chat view background color. ONLY use this tool when the user explicitly asks to change or randomize the background color. Never call this tool for normal conversation or greetings."
    
    @Generable
    struct Arguments {
        @Guide(description: "The name or hex code of the color requested by the user (e.g. red, blue, green, grey, purple, orange, pink, yellow, teal, coral, lavender, etc.), or 'random' if the user asked for a random color.")
        var color: String
    }
    
    let onChangeColor: @MainActor (String) -> String
    
    func call(arguments: Arguments) async throws -> some PromptRepresentable {
        let chosenColor = await onChangeColor(arguments.color)
        return "The background color was successfully changed to \(chosenColor)."
    }
}
