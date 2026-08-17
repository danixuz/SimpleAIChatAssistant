import SwiftUI

struct SuggestionsView: View {
    var onSelectPrompt: (String) -> Void
    
    private let suggestions = [
        "Test my Swift knowledge with a quiz",
        "Give me a 15-minute core workout",
        "Suggest a healthy smoothie recipe",
        "What's the weather in Tokyo?"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            
            Text("How can I help you today?")
                .font(.title2.bold())
            
            VStack(spacing: 10) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        onSelectPrompt(suggestion)
                    } label: {
                        Text(suggestion)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemFill))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    SuggestionsView { _ in }
}
