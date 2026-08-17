import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let isUser: Bool
    var content: String
    var card: GeneratedCard? = nil
}
