import SwiftUI

struct AutomationView: View {
    @ObservedObject var model: PulsarModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок
                    Text("Квантовая автоматизация")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                        .padding(.top)
                    
                    // Текущая автоматизация
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "atom")
                                .font(.title)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("Гравитационный резонанс")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Автоматически вращает пульсар")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("+\(String(format: "%.1f", model.autoClickerSpeed))/сек")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                Text("Ур. \(model.upgrades[1].level)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Улучшения автоматизации
                    Text("Улучшения автоматизации")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(model.upgrades.filter { $0.name == "Гравитационный резонанс" }) { upgrade in
                        AutomationUpgradeCard(upgrade: upgrade, model: model)
                    }
                    
                    // Будущие системы автоматизации
                    Text("Будущие системы")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    VStack(spacing: 12) {
                        FutureAutomationSystem(
                            icon: "waveform.path.ecg",
                            name: "Пространственный вихрь",
                            description: "Создает дополнительные частицы",
                            locked: true
                        )
                        
                        FutureAutomationSystem(
                            icon: "bolt.fill",
                            name: "Энергетический контур",
                            description: "Увеличивает множитель энергии",
                            locked: true
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }
}

struct AutomationUpgradeCard: View {
    let upgrade: Upgrade
    @ObservedObject var model: PulsarModel
    
    var cost: Double {
        upgrade.baseCost * pow(upgrade.multiplier, Double(upgrade.level))
    }
    
    var canAfford: Bool {
        model.photonEnergy >= cost
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(upgrade.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("+0.1/сек за уровень")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Уровень: \(upgrade.level)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Button(action: {
                    model.buyUpgrade(upgrade.id)
                }) {
                    Text("\(Int(cost))")
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(canAfford ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!canAfford)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct FutureAutomationSystem: View {
    let icon: String
    let name: String
    let description: String
    let locked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(locked ? .gray : .blue)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(locked ? .gray : .white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(locked ? .gray.opacity(0.6) : .white.opacity(0.7))
            }
            
            Spacer()
            
            if locked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(locked ? Color.gray.opacity(0.1) : Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}