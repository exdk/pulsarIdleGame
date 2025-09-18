// PulsarView.swift
// pulsarIdleGame
//
// Created by Виктор Юнусов on 18.09.2025

import SwiftUI

struct PulsarView: View {
    @ObservedObject var model: PulsarModel
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // Фоновое звёздное поле
                StarFieldView()
                
                // Частицы вращающегося диска
                ForEach(model.particles) { particle in
                    ParticleView(particle: particle, center: center, rotation: model.rotation, axisTilt: .pi/6)
                }
                
                // Аккреционный диск
                AccretionDiskView(center: center, model: model)
                
                // Джеты вдоль полюсов
                JetsView(center: center, model: model)
                
                // Полюса с пониженной частотой обновления
                PolesView(center: center, model: model)
                
                // Ядро пульсара
                CoreView(center: center, model: model)
            }
        }
        .drawingGroup()
    }
}

// MARK: - Звёздное поле
struct StarFieldView: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<1230 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let starSize = CGFloat.random(in: 1...1.5)
                let opacity = Double.random(in: 0.1...0.4)
                
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: starSize, height: starSize)),
                    with: .color(Color.white.opacity(opacity))
                )
            }
        }
    }
}

// MARK: - Частицы диска
struct ParticleView: View {
    let particle: Particle
    let center: CGPoint
    let rotation: Double
    let axisTilt: Double
    
    var body: some View {
        let x = center.x + CGFloat(cos(particle.angle + rotation) * particle.radius)
        let y = center.y + CGFloat(sin(particle.angle + rotation) * particle.radius * cos(axisTilt))
        
        Circle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size)
            .position(x: x, y: y)
            .opacity(particle.opacity)
            .blur(radius: 1.5)
    }
}

// MARK: - Аккреционный диск
struct AccretionDiskView: View {
    let center: CGPoint
    @ObservedObject var model: PulsarModel
    
    var body: some View {
        Circle()
            .strokeBorder(
                AngularGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.2),
                        model.pulsarColor().opacity(0.6),
                        .clear
                    ]),
                    center: .center
                ),
                lineWidth: 10
            )
            .frame(width: 180, height: 180)
            .position(center)
            .rotationEffect(.degrees(model.rotation * 5))
            .scaleEffect(x: 1.0, y: 0.85) // наклон
            .blur(radius: 8)
            .opacity(0.5)
    }
}

// MARK: - Джеты вдоль полюсов
struct JetsView: View {
    let center: CGPoint
    @ObservedObject var model: PulsarModel
    let axisTilt: Double = .pi / 6
    let jetLength: CGFloat = 80
    let jetWidth: CGFloat = 6
    
    @State private var pulse: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            ForEach(0..<2, id: \.self) { i in
                let tilt = Double(i) * .pi
                let radius: CGFloat = 50
                let x = center.x + CGFloat(cos(tilt + model.rotation * 0.5) * radius)
                let y = center.y + CGFloat(sin(tilt + model.rotation * 0.5) * radius * cos(axisTilt))
                
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.9),
                                model.pulsarColor().opacity(0.3),
                                .clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: jetWidth, height: jetLength * pulse)
                    .position(x: x, y: y)
                    .rotationEffect(.radians(tilt))
                    .opacity(0.7)
                    .blur(radius: 2)
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
            ) {
                pulse = 1.1
            }
        }
    }
}

// MARK: - Полюса
struct PolesView: View {
    let center: CGPoint
    @ObservedObject var model: PulsarModel
    @State private var lastUpdate: Date = .now
    let updateInterval: TimeInterval = 0.05 // 20fps для полюсов
    
    var body: some View {
        ForEach(0..<2, id: \.self) { i in
            let tilt = Double(i) * .pi
            let now = Date()
            let rotationOffset: Double
            if now.timeIntervalSince(lastUpdate) > updateInterval {
                rotationOffset = model.rotation * 0.5
                lastUpdate = now
            } else {
                rotationOffset = 0
            }
            
            let axisTilt = .pi / 6
            let radius: CGFloat = 50
            let x = center.x + CGFloat(cos(tilt + rotationOffset) * radius)
            let y = center.y + CGFloat(sin(tilt + rotationOffset) * radius * cos(axisTilt))
            
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)
                .position(x: x, y: y)
                .shadow(color: .white, radius: 8)
        }
    }
}

// MARK: - Ядро пульсара
struct CoreView: View {
    let center: CGPoint
    @ObservedObject var model: PulsarModel
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        .white,
                        model.pulsarColor(),
                        model.pulsarColor().opacity(0.4)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 30
                )
            )
            .frame(width: 40, height: 40)
            .position(center)
            .scaleEffect(pulseScale)
            .shadow(color: model.pulsarColor(), radius: 25)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true)
                ) {
                    pulseScale = 1.05
                }
            }
    }
}
