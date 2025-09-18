struct MainGameView: View {
    @ObservedObject var model: PulsarModel
    @State private var showPrestigeEffect = false
    
    var totalSpeed: Double {
        model.speed + model.achievementSpeedBonus
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            PulsarView(model: model)
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Скорость: \(String(format: "%.2f", totalSpeed)) об/сек")
                            .foregroundColor(.white)
                        
                        if model.achievementSpeedBonus > 0 {
                            Text("+\(String(format: "%.2f", model.achievementSpeedBonus)) от достижений")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        Text("Макс: \(String(format: "%.1f", model.maxSpeed))")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Энергия: \(Int(model.photonEnergy))")
                            .foregroundColor(.white)
                        Text("Престижей: \(model.prestigeCount)")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                }
                .padding()
                
                Spacer()
                
                // Индикатор прогресса к престижу
                VStack(spacing: 8) {
                    ProgressView(value: model.progressToPrestige, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(3)
                    
                    HStack {
                        Text("\(String(format: "%.1f", totalSpeed))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(String(format: "%.1f", model.maxSpeed))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    if model.progressToPrestige >= 1.0 {
                        Text("Готово к престижу!")
                            .font(.caption)
                            .foregroundColor(.green)
                            .bold()
                    } else {
                        Text("\(String(format: "%.1f", totalSpeed))/\(String(format: "%.1f", model.maxSpeed))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            model.accelerate()
                        }
                    }) {
                        Text("Ускорить +\(String(format: "%.1f", 0.1 * model.tapMultiplier))")
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(totalSpeed >= model.maxSpeed * 1.2 ? Color.orange : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Button(action: {
                        withAnimation {
                            model.prestige()
                            showPrestigeEffect = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showPrestigeEffect = false
                            }
                        }
                    }) {
                        Text("Престиж")
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(totalSpeed < model.maxSpeed ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(totalSpeed < model.maxSpeed)
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding()
            }
            
            if showPrestigeEffect {
                PrestigeEffectView()
                    .transition(.opacity)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            model.saveGame()
        }
    }
}