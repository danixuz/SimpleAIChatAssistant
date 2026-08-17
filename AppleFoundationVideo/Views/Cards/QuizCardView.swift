import SwiftUI

struct QuizCardView: View {
    let quiz: QuizCard
    @State private var selectedOption: Int? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Knowledge Check", systemImage: "questionmark.circle.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.tint)
                Spacer()
            }
            
            Text(quiz.question)
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(0..<quiz.options.count, id: \.self) { index in
                    Button {
                        withAnimation {
                            selectedOption = index
                        }
                    } label: {
                        HStack {
                            Text(quiz.options[index])
                                .font(.subheadline)
                                .foregroundStyle(optionTextColor(for: index))
                            Spacer()
                            if let selectedOption {
                                if index == quiz.correctIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else if index == selectedOption {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(optionBackground(for: index))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedOption != nil)
                }
            }
            
            if selectedOption != nil {
                Text(quiz.explanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                    .transition(.opacity)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    private func optionBackground(for index: Int) -> Color {
        guard let selectedOption else {
            return Color(.tertiarySystemBackground)
        }
        if index == quiz.correctIndex {
            return Color.green.opacity(0.15)
        } else if index == selectedOption {
            return Color.red.opacity(0.15)
        }
        return Color(.tertiarySystemBackground).opacity(0.5)
    }
    
    private func optionTextColor(for index: Int) -> Color {
        guard let selectedOption else { return .primary }
        if index == quiz.correctIndex { return .green }
        if index == selectedOption { return .red }
        return .secondary
    }
}
