//
//  CustomTabBar.swift
//  pulsarIdleGame
//
//  Created by Виктор Юнусов on 14.09.2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @ObservedObject var model: PulsarModel
    @State private var showMoreMenu = false
    
    let tabs = [
        (icon: "star", name: "Пульсар", tag: 0),
        (icon: "atom", name: "Автоматизация", tag: 1),
        (icon: "moon.stars", name: "Оффлайн", tag: 2),
        (icon: "chart.line.uptrend.xyaxis", name: "Улучшения", tag: 3),
        (icon: "ellipsis", name: "Еще", tag: 4)
    ]
    
    var body: some View {
        ZStack {
            // Основной таббар
            HStack {
                ForEach(tabs.prefix(4), id: \.tag) { tab in
                    TabBarButton(
                        icon: tab.icon,
                        name: tab.name,
                        isSelected: selectedTab == tab.tag,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = tab.tag
                            }
                        }
                    )
                    .frame(maxWidth: .infinity)
                }
                
                // Кнопка "Еще"
                TabBarButton(
                    icon: "ellipsis",
                    name: "Еще",
                    isSelected: selectedTab >= 5,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showMoreMenu.toggle()
                        }
                    }
                )
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            )
            
            // Выпадающее меню
            if showMoreMenu {
                MoreMenuView(
                    isVisible: $showMoreMenu,
                    selectedTab: $selectedTab,
                    model: model
                )
            }
        }
        .frame(height: 60)
    }
}

struct TabBarButton: View {
    let icon: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(
                        isSelected ?
                        LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                    )
                
                Text(name)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .cyan : .gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
    }
}