import SwiftUI

struct OfflineView: View {
    @ObservedObject var model: PulsarModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок
                    Text("Квантовое вознаграждение")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                        .padding(.top)
                    
                    // Карточка оффлайн дохода
                    VStack(spacing: 15) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Время отсутствия:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if model.offlineTime > 0 {
                            Text(timeString(from: model.offlineTime))
                                .font(.title3)
                                .foregroundColor(.green)
                            
                            Text("+\(Int(model.offlineEarnings)) энергии")
                                .font(.title3)
                                .foregroundColor(.yellow)
                        } else {
                            Text("Менее минуты")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            Text("Доход не начислен")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        Text("Оффлайн доход составляет 30% от онлайн-дохода")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Статистика
                    VStack(spacing: 12) {
                        Text("Текущие показатели")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            VStack {
                                Text("\(String(format: "%.1f", model.effectiveSpeed))")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("об/сек")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("\(String(format: "%.1f", model.autoClickerSpeed))")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                Text("авто/сек")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("\(Int(model.offlineEarningsPerHour))")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                Text("в час")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Улучшения оффлайн дохода
                    Text("Улучшения оффлайн дохода")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    // Здесь можно добавить будущие улучшения для оффлайн дохода
                    VStack {
                        Text("Скоро появятся улучшения для увеличения оффлайн дохода!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            model.applyOfflineEarnings()
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return "\(hours)ч \(minutes)м \(seconds)с"
        } else if minutes > 0 {
            return "\(minutes)м \(seconds)с"
        } else {
            return "\(seconds)с"
        }
    }
}

// Добавим computed property в PulsarModel для расчета дохода в час
extension PulsarModel {
    var offlineEarningsPerHour: Double {
        effectiveSpeed * 3600 * 0.3 // 30% от часового дохода
    }
}