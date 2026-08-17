import Foundation
import FoundationModels

struct GenerateWorkoutTool: Tool {
    let name = "generateWorkout"
    let description = "Generates an interactive workout routine card. Use this tool when the user asks for a workout plan, exercise routine, or fitness session."
    
    typealias Arguments = WorkoutCard
    
    let onGenerate: @MainActor (WorkoutCard) -> Void
    
    func call(arguments: Arguments) async throws -> some PromptRepresentable {
        await onGenerate(arguments)
        return "Interactive workout plan card displayed for the user."
    }
}
