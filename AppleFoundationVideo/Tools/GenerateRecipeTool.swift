import Foundation
import FoundationModels

struct GenerateRecipeTool: Tool {
    let name = "generateRecipe"
    let description = "Generates an interactive recipe card. Use this tool when the user asks for a recipe, meal idea, or cooking instructions."
    
    typealias Arguments = RecipeCard
    
    let onGenerate: @MainActor (RecipeCard) -> Void
    
    func call(arguments: Arguments) async throws -> some PromptRepresentable {
        await onGenerate(arguments)
        return "Interactive recipe card displayed for the user."
    }
}
