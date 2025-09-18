import SwiftUI

struct OfflineRewardView: View {
    @ObservedObject var model: PulsarModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "clock.badge.checkmark")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                
                Text("Возвращаемся в игру!")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                
                VStack(spacing: 10) {
                    Text("Время отсутствия:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(timeString(from: model.offlineTime))
                        .font(.title3)
                        .foregroundColor(.green)
                    
                    Text("+\(Int(model.lastOfflineEarnings)) энергии")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    Text("+\(String(format: "%.1f", model.offlineTime / 60)) минут в банке времени")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Text("Накоплено времени: \(String(format: "%.1f", model.offlineTimeBank)) минут")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Button(action: {
                    model.claimOfflineReward()
                    dismiss()
                }) {
                    Text("Забрать награду")
                        .fontWeight(.bold)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            .padding(.horizontal, 40)
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