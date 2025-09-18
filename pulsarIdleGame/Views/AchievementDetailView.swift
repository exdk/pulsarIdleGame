// Для подробного просмотра при тапе можно добавить модальное окно
struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    if achievement.isUnlocked {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.gray.opacity(0.3), .gray.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                    }
                    
                    Image(systemName: achievement.isUnlocked ? "medal.fill" : "medal")
                        .font(.system(size: 30))
                        .foregroundColor(achievement.isUnlocked ? .white : .gray)
                }
                
                Text(achievement.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if achievement.isUnlocked, let unlockDate = achievement.unlockDate {
                    VStack(spacing: 4) {
                        Text("Разблокировано:")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        
                        Text(unlockDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(unlockDate, style: .time)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 8)
                } else {
                    Text("Не разблокировано")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                
                Button("Закрыть") {
                    dismiss()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .padding()
        }
    }
}