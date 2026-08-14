import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    @AppStorage("useTypingIndicator") private var useTypingIndicator: Bool = true
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 40)
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            } else {
                Image(systemName: "sparkles")
                    .foregroundStyle(.tint)
                    .padding(.top, 4)
                
                if message.content.isEmpty {
                    if useTypingIndicator {
                        TypingIndicatorView()
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    } else {
                        ProgressView()
                            .padding(.vertical, 8)
                    }
                } else {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                
                Spacer(minLength: 40)
            }
        }
    }
}

#Preview {
    VStack {
        MessageBubble(message: ChatMessage(isUser: true, content: "Hello AI!"))
        MessageBubble(message: ChatMessage(isUser: false, content: ""))
        MessageBubble(message: ChatMessage(isUser: false, content: "Hello! How can I help you today?"))
    }
    .padding()
}
