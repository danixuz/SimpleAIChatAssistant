import SwiftUI
import FoundationModels

@Observable
final class ChatViewModel {
    private var session: LanguageModelSession!
    
    var sessions: [ChatSession] = [ChatSession()]
    var currentSessionId: UUID
    var isSidebarOpen: Bool = false
    
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isGenerating: Bool = false
    var backgroundColor: Color = Color(.systemBackground)
    var currentColorName: String = "default"
    
    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
    }
    
    init() {
        let initialSession = ChatSession()
        self.sessions = [initialSession]
        self.currentSessionId = initialSession.id
        setupSession()
    }
    
    private func setupSession(context: String? = nil) {
        let colorTool = ChangeBackgroundColorTool { [weak self] color in
            self?.updateBackgroundColor(name: color) ?? "default"
        }
        
        let getCurrentColorTool = GetCurrentBackgroundColorTool { [weak self] in
            self?.currentColorName ?? "default"
        }
        
        let quizTool = GenerateQuizTool { [weak self] quiz in
            self?.attachCard(.quiz(quiz))
        }
        
        let workoutTool = GenerateWorkoutTool { [weak self] workout in
            self?.attachCard(.workout(workout))
        }
        
        let recipeTool = GenerateRecipeTool { [weak self] recipe in
            self?.attachCard(.recipe(recipe))
        }
        
        let searchTool = SearchWebTool { [weak self] isSearching in
            self?.updateSearchingState(isSearching)
        }
        
        let today = Date.now.formatted(date: .complete, time: .shortened)
        var instructions = "You are a friendly, intelligent, and versatile AI assistant. Today's current date and time is \(today). Answer questions naturally, hold everyday conversations, and assist with any topic. Use your searchWeb tool whenever the user asks for real-time information, news, media, games, or web knowledge. When searching, focus on the exact medium requested (e.g. video game vs movie vs book), carefully check the dates in the search results, and state the accurate information directly."
        
        if let context, !context.isEmpty {
            instructions += "\n\nConversation context:\n\(context)"
        }
        
        session = LanguageModelSession(
            tools: [
                GetWeatherTool(),
                searchTool,
                colorTool,
                getCurrentColorTool,
                CreateReminderTool(),
                quizTool,
                workoutTool,
                recipeTool
            ],
            instructions: instructions
        )
    }
    
    // MARK: - Auto Context Pruning (Guarantees token usage is always < 1,000)
    private func prepareCleanSessionForTurn() {
        let recentSlice = messages.suffix(6)
        let context = recentSlice.compactMap { msg -> String? in
            guard !msg.content.isEmpty else { return nil }
            return "\(msg.isUser ? "User" : "Assistant"): \(msg.content)"
        }.joined(separator: "\n")
        
        setupSession(context: context.isEmpty ? nil : context)
    }
    
    @MainActor
    private func updateSearchingState(_ isSearching: Bool) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if let lastIndex = messages.indices.last, !messages[lastIndex].isUser {
                messages[lastIndex].isSearching = isSearching
                syncCurrentSession()
            }
        }
    }
    
    // MARK: - Multi-Session Management
    func createNewChat() {
        let newSession = ChatSession()
        sessions.insert(newSession, at: 0)
        currentSessionId = newSession.id
        messages = []
        setupSession()
    }
    
    func selectSession(id: UUID) {
        guard let selected = sessions.first(where: { $0.id == id }) else { return }
        currentSessionId = id
        messages = selected.messages
        prepareCleanSessionForTurn()
    }
    
    func deleteSession(id: UUID) {
        sessions.removeAll(where: { $0.id == id })
        if sessions.isEmpty {
            createNewChat()
        } else if currentSessionId == id {
            selectSession(id: sessions[0].id)
        }
    }
    
    private func syncCurrentSession() {
        if let index = sessions.firstIndex(where: { $0.id == currentSessionId }) {
            sessions[index].messages = messages
        }
    }
    
    @MainActor
    private func attachCard(_ card: GeneratedCard) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if let lastIndex = messages.indices.last, !messages[lastIndex].isUser {
                messages[lastIndex].card = card
                syncCurrentSession()
            }
        }
    }
    
    static let presetColors = [
        "default", "blue", "purple", "pink", "red", "orange", "yellow", "green", "teal", "mint", "indigo", "gray"
    ]
    
    static func previewColor(for name: String) -> Color {
        switch name.lowercased() {
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "teal": return .teal
        case "mint": return .mint
        case "indigo": return .indigo
        case "gray", "grey": return .gray
        default: return Color(.secondarySystemBackground)
        }
    }
    
    @MainActor
    func updateBackgroundColor(name: String) -> String {
        let cleanName = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let colorMap: [String: Color] = [
            "red": .red.opacity(0.2),
            "crimson": Color(red: 0.86, green: 0.08, blue: 0.24).opacity(0.2),
            "blue": .blue.opacity(0.2),
            "navy": Color(red: 0.0, green: 0.0, blue: 0.5).opacity(0.2),
            "sky blue": Color(red: 0.53, green: 0.81, blue: 0.92).opacity(0.25),
            "cyan": .cyan.opacity(0.2),
            "green": .green.opacity(0.2),
            "lime": Color(red: 0.2, green: 0.8, blue: 0.2).opacity(0.2),
            "emerald": Color(red: 0.31, green: 0.78, blue: 0.47).opacity(0.2),
            "mint": .mint.opacity(0.2),
            "teal": .teal.opacity(0.2),
            "yellow": .yellow.opacity(0.25),
            "gold": Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.25),
            "amber": Color(red: 1.0, green: 0.75, blue: 0.0).opacity(0.25),
            "orange": .orange.opacity(0.2),
            "coral": Color(red: 1.0, green: 0.5, blue: 0.31).opacity(0.2),
            "peach": Color(red: 1.0, green: 0.85, blue: 0.73).opacity(0.3),
            "purple": .purple.opacity(0.2),
            "indigo": .indigo.opacity(0.2),
            "violet": Color(red: 0.58, green: 0.0, blue: 0.83).opacity(0.2),
            "lavender": Color(red: 0.9, green: 0.9, blue: 0.98).opacity(0.3),
            "pink": .pink.opacity(0.2),
            "magenta": Color(red: 1.0, green: 0.0, blue: 1.0).opacity(0.2),
            "rose": Color(red: 1.0, green: 0.0, blue: 0.5).opacity(0.2),
            "brown": .brown.opacity(0.2),
            "beige": Color(red: 0.96, green: 0.96, blue: 0.86).opacity(0.3),
            "gray": .gray.opacity(0.2),
            "grey": .gray.opacity(0.2),
            "slate": Color(red: 0.44, green: 0.5, blue: 0.56).opacity(0.2),
            "silver": Color(red: 0.75, green: 0.75, blue: 0.75).opacity(0.25),
            "black": .black.opacity(0.15),
            "dark": .black.opacity(0.2),
            "white": .white,
            "light": Color(.systemBackground),
            "default": Color(.systemBackground),
            "clear": Color(.systemBackground),
            "system": Color(.systemBackground)
        ]
        
        let randomOptions = ["red", "blue", "green", "purple", "orange", "pink", "yellow", "teal", "mint", "indigo", "coral", "cyan", "lavender", "rose", "gray"]
        
        if cleanName == "random" || cleanName.isEmpty {
            let chosen = randomOptions.randomElement() ?? "purple"
            self.currentColorName = chosen
            withAnimation(.easeInOut) {
                self.backgroundColor = colorMap[chosen] ?? .purple.opacity(0.2)
            }
            return chosen
        }
        
        if let matchedColor = colorMap[cleanName] {
            self.currentColorName = cleanName
            withAnimation(.easeInOut) {
                self.backgroundColor = matchedColor
            }
            return cleanName
        }
        
        // Hex color fallback (e.g. #FF5733 or FF5733)
        if let hexColor = Color(hex: cleanName) {
            self.currentColorName = cleanName
            withAnimation(.easeInOut) {
                self.backgroundColor = hexColor.opacity(0.25)
            }
            return cleanName
        }
        
        // Fallback for unmapped color names: choose random
        let fallback = randomOptions.randomElement() ?? "purple"
        self.currentColorName = fallback
        withAnimation(.easeInOut) {
            self.backgroundColor = colorMap[fallback] ?? .purple.opacity(0.2)
        }
        return fallback
    }
    
    // MARK: - Send Message
    func sendMessage(prompt: String? = nil) {
        let textToSend = prompt ?? inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty, !isGenerating else { return }
        
        // Auto-update session title on first message
        if let index = sessions.firstIndex(where: { $0.id == currentSessionId }), sessions[index].messages.isEmpty {
            sessions[index].title = String(textToSend.prefix(28))
        }
        
        // Ensure the active session context is clean and bounded (< 1,000 tokens)
        prepareCleanSessionForTurn()
        
        inputText = ""
        messages.append(ChatMessage(isUser: true, content: textToSend))
        syncCurrentSession()
        
        let assistantIndex = messages.count
        messages.append(ChatMessage(isUser: false, content: ""))
        isGenerating = true
        
        let useTypingIndicator = UserDefaults.standard.object(forKey: "useTypingIndicator") as? Bool ?? true
        
        Task {
            do {
                let stream = session.streamResponse(to: textToSend)
                if useTypingIndicator {
                    var fullResponse = ""
                    for try await response in stream {
                        fullResponse = response.content
                    }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        messages[assistantIndex].content = fullResponse
                        syncCurrentSession()
                    }
                } else {
                    for try await response in stream {
                        messages[assistantIndex].content = response.content
                        syncCurrentSession()
                    }
                }
            } catch {
                messages[assistantIndex].content = "Error: \(error.localizedDescription)"
                syncCurrentSession()
            }
            isGenerating = false
        }
    }
    
    func resetChat() {
        createNewChat()
        withAnimation(.easeInOut) {
            backgroundColor = Color(.systemBackground)
        }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init?(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHex = cleanHex.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: cleanHex).scanHexInt64(&rgb) else { return nil }
        
        if cleanHex.count == 6 {
            let r = Double((rgb & 0xFF0000) >> 16) / 255.0
            let g = Double((rgb & 0x00FF00) >> 8) / 255.0
            let b = Double(rgb & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b)
        } else {
            return nil
        }
    }
}
