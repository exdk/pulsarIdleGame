struct PrestigeEffectView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            ForEach(0..<20) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.white, .yellow, .clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 15
                        )
                    )
                    .frame(width: 6, height: 6)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .offset(x: CGFloat(cos(Double(i) * 0.3) * 150 * scale),
                            y: CGFloat(sin(Double(i) * 0.3) * 150 * scale))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                scale = 2.5
                opacity = 0.0
            }
        }
    }
}