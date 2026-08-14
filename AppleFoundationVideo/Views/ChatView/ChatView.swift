import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var isMessageTypedIn = false
    @State private var showSettings = false
    @FocusState private var isInputFocused: Bool
    @Namespace var namespace1
    @Namespace var namespace2
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.messages.isEmpty {
                    SuggestionsView { suggestion in
                        isInputFocused = false
                        viewModel.sendMessage(prompt: suggestion)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isInputFocused = false
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.resetChat) {
                        Image(systemName: "square.and.pencil")
                    }
                    .disabled(viewModel.messages.isEmpty || viewModel.isGenerating)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
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
                    }
                    
                    Color.clear
                        .frame(height: 80)
                        .id("bottom")
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .scrollDismissesKeyboard(.interactively)
            .contentShape(Rectangle())
            .onTapGesture {
                isInputFocused = false
            }
            .onChange(of: viewModel.messages.last?.content) {
                withAnimation {
                    proxy.scrollTo("bottom")
                }
            }
            .onChange(of: isInputFocused) {
                if isInputFocused {
                    withAnimation {
                        proxy.scrollTo("bottom")
                    }
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
                    .focused($isInputFocused)
                    .textInputAutocapitalization(.sentences)
                    .padding()
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 26.5))
                    .glassEffectID("messagetextfield", in: namespace1)
                    .glassEffectTransition(.matchedGeometry)
                    .onSubmit {
                        isInputFocused = false
                        viewModel.sendMessage()
                    }
                    .onChange(of: viewModel.inputText) { oldValue, newValue in
                        withAnimation {
                            isMessageTypedIn = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        }
                    }

                if isMessageTypedIn || viewModel.isGenerating {
                    Button {
                        isInputFocused = false
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
