struct AchievementToast: View {
    let achievement: Achievement
    @State private var show = true
    
    var body: some View {
        VStack(spacing: 8) {
            Text("🎉 Достижение!")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(achievement.title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 10)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    show = false
                }
            }
        }
        .opacity(show ? 1 : 0)
    }
}