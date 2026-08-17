import SwiftUI

struct GeminiGlowBackgroundView: View {
    let isGenerating: Bool
    let baseColor: Color
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            baseColor
            
            // Glowing Ambient Gradient Orbs
            VStack {
                ZStack {
                    // Orb 1: Purple & Blue
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.45), Color.blue.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 330, height: 330)
                        .blur(radius: 75)
                        .offset(x: sin(phase) * 60 - 40, y: cos(phase) * 80 - 190)
                    
                    // Orb 2: Cyan & Pink
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.45), Color.pink.opacity(0.35)],
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            )
                        )
                        .frame(width: 330, height: 330)
                        .blur(radius: 75)
                        .offset(x: cos(phase) * 60, y: sin(phase) * 70 - 80)
                    
                    // Orb 3: Indigo & Teal
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.indigo.opacity(0.35), Color.teal.opacity(0.3)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
//                        .frame(width: 400, height: 400)
                        .blur(radius: 75)
                        .offset(x: sin(phase * 0.5) * 50, y: cos(phase * 0.8) * -190)
                }
                .ignoresSafeArea()
                .opacity(isGenerating ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 1.4), value: isGenerating)
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}

#Preview {
    GeminiGlowBackgroundView(isGenerating: true, baseColor: Color(.systemBackground))
}
