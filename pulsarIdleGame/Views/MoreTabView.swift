//
//  MoreTabView.swift
//  pulsarIdleGame
//
//  Created by Виктор Юнусов on 14.09.2025.
//

import SwiftUI

struct MoreTabView: View {
    @Binding var selectedTab: Int
    @ObservedObject var model: PulsarModel
    @State private var showMenu = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Выпадающее меню снизу
                if showMenu {
                    VStack(spacing: 0) {
                        MenuButton(
                            icon: "medal",
                            title: "Достижения",
                            badgeCount: model.badgeState.badgeCount
                        ) {
                            selectedTab = 5
                            showMenu = false
                        }
                        
                        MenuButton(
                            icon: "gear",
                            title: "Настройки"
                        ) {
                            selectedTab = 6
                            showMenu = false
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
                
                // Кнопка открытия/закрытия меню
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showMenu.toggle()
                    }
                }) {
                    Image(systemName: showMenu ? "chevron.down" : "ellipsis")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    var badgeCount: Int = 0
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 30)
                
                Text(title)
                    .font(AppFont.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}