import SwiftUI

struct SidebarView: View {
    let viewModel: ChatViewModel
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.tint)
                
                Text("Chat History")
                    .font(.title3.bold())
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        viewModel.createNewChat()
                        viewModel.isSidebarOpen = false
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(8)
                        .background(Color(.secondarySystemFill))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 16)
            
            Divider()
                .padding(.horizontal, 16)
            
            // Sessions List
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.sessions) { session in
                        sessionRow(session)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            // Footer: Settings row
            Button {
                showSettings = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.tint)
                        .frame(width: 32, height: 32)
                        .background(Color(.secondarySystemFill))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Settings")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)
                        
                        Text("Appearance & Features")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(.systemBackground)
                .ignoresSafeArea()
        )
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(Color.primary.opacity(0.08)),
            alignment: .trailing
        )
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
    }
    
    private func sessionRow(_ session: ChatSession) -> some View {
        let isSelected = session.id == viewModel.currentSessionId
        
        return HStack(spacing: 12) {
            Image(systemName: isSelected ? "bubble.left.and.text.bubble.right.fill" : "bubble.left")
                .font(.system(size: 16))
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            
            Text(session.title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                .lineLimit(1)
            
            Spacer()
            
            if viewModel.sessions.count > 1 {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.deleteSession(id: session.id)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(0.5))
                        .padding(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                viewModel.selectSession(id: session.id)
                viewModel.isSidebarOpen = false
            }
        }
    }
}

#Preview {
    SidebarView(viewModel: ChatViewModel())
}
