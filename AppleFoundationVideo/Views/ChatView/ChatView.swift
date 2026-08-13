import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var isMessageTypedIn = false
    @Namespace var namespace1
    @Namespace var namespace2
    
    var body: some View {
        NavigationStack {
            ZStack() {
                if viewModel.messages.isEmpty {
                    SuggestionsView { suggestion in
                        viewModel.sendMessage(prompt: suggestion)
                    }
                } else {
                    messageListView
                }
                
                inputBar
            }
            .background(viewModel.backgroundColor.ignoresSafeArea())
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.resetChat) {
                        Image(systemName: "square.and.pencil")
                    }
                    .disabled(viewModel.messages.isEmpty || viewModel.isGenerating)
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .all)
        }
    }
    
    // MARK: - Message List View
    private var messageListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.last?.content) { _, _ in
                if let lastId = viewModel.messages.last?.id {
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            }
        }
    }
    
    // MARK: - Input Bar
    private var inputBar: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                TextField("Message...", text: $viewModel.inputText, axis: .vertical)
                    .textInputAutocapitalization(.sentences)
                    .padding()
                    .glassEffect(.regular.interactive())
                    .glassEffectID("messagetextfield", in: namespace1)
                    .glassEffectTransition(.matchedGeometry)
                    .onChange(of: viewModel.inputText) { oldValue, newValue in
                        withAnimation {
                            isMessageTypedIn = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        }
                    }

                if isMessageTypedIn || viewModel.isGenerating {
                    Button {
                        Task {
                            viewModel.sendMessage()
                        }
                    } label: {
                        Image(systemName: viewModel.isGenerating ? "stop" : "arrow.up")
                                            .font(.system(size: 20))
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(viewModel.canSend ? Color.accentColor : Color.gray.opacity(0.4))
                                            .padding()
                    }
                    .glassEffect(.regular.interactive())
                    .glassEffectID("sendbutton", in: namespace1)
                    .glassEffectTransition(.matchedGeometry)
                    .tint(.primary)
                    .disabled(!viewModel.canSend && !viewModel.isGenerating)
                } else {
                    // TODO: Implement media sending support.
                    GlassEffectContainer {
                        
                        Button {
                            // Add other attachement
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .padding()
                        }
                        .glassEffect(.regular.interactive())
                        .glassEffectUnion(id: 1, namespace: namespace2)
                        .glassEffectID("plusbutton", in: namespace1)
                        .glassEffectTransition(.matchedGeometry)
                        .tint(.primary)
                    }
                    .fixedSize(horizontal: true, vertical: true)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
}

#Preview {
    ChatView()
}
