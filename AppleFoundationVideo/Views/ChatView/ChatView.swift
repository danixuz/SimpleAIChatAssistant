import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var isMessageTypedIn = false
    @FocusState private var isInputFocused: Bool
    @Namespace var namespace1
    @Namespace var namespace2
    
    private let sidebarWidth: CGFloat = 310
    
    var body: some View {
        ZStack(alignment: .leading) {
            // MARK: - Main Chat View
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
                .background(
                    GeminiGlowBackgroundView(
                        isGenerating: viewModel.isGenerating,
                        baseColor: viewModel.backgroundColor
                    )
                )
                .navigationTitle("AI Assistant")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isInputFocused = false
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                viewModel.isSidebarOpen.toggle()
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isInputFocused = false
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                viewModel.createNewChat()
                            }
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
                .scrollEdgeEffectStyle(.soft, for: .all)
            }
            
            // MARK: - Dimming Backdrop
            Color.black
                .opacity(viewModel.isSidebarOpen ? 0.4 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(viewModel.isSidebarOpen)
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        viewModel.isSidebarOpen = false
                    }
                }
            
            // MARK: - Slide-Out Sidebar Drawer
            SidebarView(viewModel: viewModel)
                .frame(width: sidebarWidth)
                .offset(x: viewModel.isSidebarOpen ? 0 : -(sidebarWidth + 20))
                .shadow(color: .black.opacity(viewModel.isSidebarOpen ? 0.3 : 0), radius: 25, x: 8, y: 0)
                .ignoresSafeArea(.container, edges: .vertical)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.isSidebarOpen)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 60 && value.startLocation.x < 50 {
                        // Swipe from left edge to open
                        isInputFocused = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            viewModel.isSidebarOpen = true
                        }
                    } else if value.translation.width < -60 && viewModel.isSidebarOpen {
                        // Swipe left to close
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            viewModel.isSidebarOpen = false
                        }
                    }
                }
        )
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
            .animation(.default, value: isInputFocused)
            .padding(.horizontal)
            .padding(.bottom, isInputFocused ? 10 : 5)
        }
    }
}

#Preview {
    ChatView()
}
