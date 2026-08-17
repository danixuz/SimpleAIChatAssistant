import Foundation
import FoundationModels

struct GenerateQuizTool: Tool {
    let name = "generateQuiz"
    let description = "Generates an interactive multiple-choice quiz question. Use this tool when the user asks for a quiz, trivia, or to test their knowledge on a topic."
    
    typealias Arguments = QuizCard
    
    let onGenerate: @MainActor (QuizCard) -> Void
    
    func call(arguments: Arguments) async throws -> some PromptRepresentable {
        await onGenerate(arguments)
        return "Interactive quiz card displayed for the user."
    }
}
