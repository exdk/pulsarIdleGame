//
//  LaunchScreenView.swift
//  pulsarIdleGame
//
//  Created by Виктор Юнусов on 14.09.2025.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isLoading = false
    @State private var isVisible = true
    @Binding var isActive: Bool
    
    var body: some View {
        if isVisible {
            ZStack {
                // Космический фон
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.05, blue: 0.15), Color(red: 0.1, green: 0.05, blue: 0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Логотип игры
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.blue, .purple, .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .blue, .purple],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .blue.opacity(0.8), radius: 20, x: 0, y: 0)
                    }
                    
                    // Название игры
                    Text("PULSAR IDLE")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.6), radius: 10, x: 0, y: 0)
                    
                    // Индикатор загрузки
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 200, height: 6)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: isLoading ? 200 : 0, height: 6)
                            .animation(
                                .easeInOut(duration: 2.0),
                                value: isLoading
                            )
                    }
                    
                    // Подпись разработчика
                    Text("by Victor Yunusov")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .onAppear {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isVisible = false
                        isActive = true
                    }
                }
            }
        }
    }
}