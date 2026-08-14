import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("useTypingIndicator") private var useTypingIndicator: Bool = true
    let viewModel: ChatViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $useTypingIndicator) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Typing Indicator")
                                Text("Show 3 bouncing dots while the AI generates.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "ellipsis.bubble")
                                .foregroundStyle(.tint)
                        }
                    }
                } header: {
                    Text("Chat Experience")
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ChatViewModel.presetColors, id: \.self) { colorName in
                                Button {
                                    _ = viewModel.updateBackgroundColor(name: colorName)
                                } label: {
                                    Circle()
                                        .fill(ChatViewModel.previewColor(for: colorName))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button {
                        _ = viewModel.updateBackgroundColor(name: "random")
                    } label: {
                        Label("Randomize Color", systemImage: "dice")
                    }
                    
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.backgroundColor = Color(.systemBackground)
                        }
                    } label: {
                        Label("Reset to Default", systemImage: "arrow.counterclockwise")
                    }
                } header: {
                    Text("Background Color")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: ChatViewModel())
}
