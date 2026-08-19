import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    @AppStorage("useTypingIndicator") private var useTypingIndicator: Bool = true
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 40)
                Text(LocalizedStringKey(message.content))
                    .textSelection(.enabled)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = message.content
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
            } else {
                Image(systemName: "sparkles")
                    .foregroundStyle(.tint)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    if let card = message.card {
                        switch card {
                        case .quiz(let quiz):
                            QuizCardView(quiz: quiz)
                        case .workout(let workout):
                            WorkoutCardView(workout: workout)
                        case .recipe(let recipe):
                            RecipeCardView(recipe: recipe)
                        }
                    } else if !message.content.isEmpty {
                        Text(LocalizedStringKey(message.content))
                            .textSelection(.enabled)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .contextMenu {
                                Button {
                                    UIPasteboard.general.string = message.content
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                            }
                    } else {
                        if message.isSearching {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Searching...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        } else if useTypingIndicator {
                            TypingIndicatorView()
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        } else {
                            ProgressView()
                                .padding(.vertical, 8)
                        }
                    }
                }
                
                Spacer(minLength: 40)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MessageBubble(message: ChatMessage(isUser: true, content: "Test my Swift knowledge!"))
        MessageBubble(message: ChatMessage(
            isUser: false,
            content: "Here is a quick question for you:",
            card: .quiz(QuizCard(
                question: "What is an Optional in Swift?",
                options: ["A type that represents either a wrapped value or nil", "A forced unwrapping operator", "A struct that cannot be mutated"],
                correctIndex: 0,
                explanation: "Optionals in Swift represent either a wrapped value or the absence of a value (nil)."
            ))
        ))
    }
    .padding()
}
