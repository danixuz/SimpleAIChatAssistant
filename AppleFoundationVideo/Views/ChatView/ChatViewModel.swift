import SwiftUI
import FoundationModels

@Observable
final class ChatViewModel {
    private var session = LanguageModelSession(instructions: "You are a helpful and concise AI assistant.")
    
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isGenerating: Bool = false
    
    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
    }
    
    func sendMessage(prompt: String? = nil) {
        let textToSend = prompt ?? inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty, !isGenerating else { return }
        
        inputText = ""
        messages.append(ChatMessage(isUser: true, content: textToSend))
        
        let assistantIndex = messages.count
        messages.append(ChatMessage(isUser: false, content: ""))
        isGenerating = true
        
        Task {
            do {
                let stream = session.streamResponse(to: textToSend)
                for try await response in stream {
                    messages[assistantIndex].content = response.content
                }
            } catch {
                messages[assistantIndex].content = "Error: \(error.localizedDescription)"
            }
            isGenerating = false
        }
    }
    
    func resetChat() {
        session = LanguageModelSession(instructions: "You are a helpful and concise AI assistant.")
        messages.removeAll()
    }
}
