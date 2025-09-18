struct UpgradesView: View {
    @ObservedObject var model: PulsarModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    Text("Улучшения")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    ForEach(model.upgrades) { upgrade in
                        UpgradeCard(upgrade: upgrade, model: model)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

struct UpgradeCard: View {
    let upgrade: Upgrade
    @ObservedObject var model: PulsarModel
    
    var cost: Double {
        upgrade.baseCost * pow(upgrade.multiplier, Double(upgrade.level))
    }
    
    var canAfford: Bool {
        model.photonEnergy >= cost
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(upgrade.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(upgrade.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
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
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(canAfford ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!canAfford)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}