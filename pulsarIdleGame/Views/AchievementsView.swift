struct AchievementsView: View {
    @ObservedObject var model: PulsarModel
    
    private var gridColumns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }
    
    var totalSpeedBonus: Double {
        Double(model.achievements.filter { $0.isUnlocked }.count) * 0.01
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Статистика сверху
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Достижения")
                                .font(.title2)
                                .foregroundColor(.white)
                                .bold()
                            
                            Text("Разблокировано: \(model.achievements.filter { $0.isUnlocked }.count)/\(model.achievements.count)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("+\(String(format: "%.2f", totalSpeedBonus)) об/сек")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("Общий бонус")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Сетка достижений
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(model.achievements) { achievement in
                            AchievementGridCard(achievement: achievement)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
        }
        .onAppear {
            // Помечаем все достижения как прочитанные при открытии вкладки
            for achievement in model.achievements.filter({ $0.isNew }) {
                model.markAchievementAsRead(achievement.id)
            }
        }
    }
}