//
//  SettingsView.swift
//  pulsarIdleGame
//
//  Created by Виктор Юнусов on 13.09.2025.
//

import SwiftUI
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

class Settings: ObservableObject {
    @Published var hapticFeedback: Bool = true
}

struct SettingsView: View {
    @ObservedObject var model: PulsarModel
    @StateObject private var settings = Settings()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Form {
                Section(header: Text("Обратная связь")
                            .foregroundColor(.white)) {
                    Toggle("Виброотклик", isOn: $settings.hapticFeedback)
                        .foregroundColor(.white)
                        .onChange(of: settings.hapticFeedback) { value in
                            if value {
                                HapticManager.shared.impact(style: .medium)
                            }
                        }
                }
                .listRowBackground(Color.white.opacity(0.1))
                
                Section(header: Text("Информация")
                            .foregroundColor(.white)) {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(.white)
                    
                    HStack {
                        Text("Разработчик")
                        Spacer()
                        Text("Виктор Юнусов")
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(.white)
                }
                .listRowBackground(Color.white.opacity(0.1))
            }
            .scrollContentBackground(.hidden)
            .foregroundColor(.white)
        }
    }
}
