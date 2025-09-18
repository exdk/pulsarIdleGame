//
//  PulsarModel.swift
//  pulsarIdleGame
//
//  Created by Виктор Юнусов on 12.09.2025.
//

import SwiftUI
import Combine

struct Particle: Identifiable {
    let id = UUID()
    var angle: Double
    var radius: Double
    var opacity: Double
    let color: Color
    let creationTime: Date
    let size: CGFloat
}

struct Upgrade: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let baseCost: Double
    let multiplier: Double
    var level: Int = 0
    var isUnlocked: Bool = false
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let condition: (PulsarModel) -> Bool
    var isUnlocked: Bool = false
    var isNew: Bool = false
    var unlockDate: Date? = nil
}

struct OfflineUpgrade: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let baseCost: Double // Стоимость в оффлайн-минутах
    let multiplier: Double
    let effect: (Double) -> Double // Эффект улучшения
    var level: Int = 0
    var isUnlocked: Bool = false
}

class PulsarModel: ObservableObject {
    @Published var speed: Double = 2.0
    @Published var maxSpeed: Double = 100.0
    @Published var photonEnergy: Double = 0.0
    @Published var rotation: Double = 0.0
    @Published var particles: [Particle] = []
    @Published var prestigeCount: Int = 0
    @Published var showAchievementToast: Achievement?
    @Published var badgeState = BadgeState()
    @Published var settings = Settings()
    @Published var lastSaveTime: Date = Date()
    @Published var offlineEarnings: Double = 0
    @Published var offlineTime: TimeInterval = 0
    @Published var offlineTimeBank: Double = 0 // Накопленные минуты оффлайн-времени
    @Published var showOfflineReward: Bool = false
    @Published var lastOfflineEarnings: Double = 0
    
    @Published var upgrades: [Upgrade] = [
        Upgrade(name: "Усиленный тап", description: "+0.2 за клик", baseCost: 100, multiplier: 1.5),
        Upgrade(name: "Гравитационный резонанс", description: "+0.1/сек автоматически", baseCost: 500, multiplier: 2.0),
        Upgrade(name: "Энергетический резонанс", description: "×1.5 к энергии за клик", baseCost: 1000, multiplier: 2.5),
        Upgrade(name: "Квантовое ускорение", description: "×2 к скорости вращения", baseCost: 2000, multiplier: 3.0)
    ]
    
    @Published var achievements: [Achievement] = [
        Achievement(title: "Первое вращение", description: "Достигните 10 об/сек", condition: { $0.speed >= 10 }),
        Achievement(title: "Скоростной демон", description: "Достигните 50 об/сек", condition: { $0.speed >= 50 }),
        Achievement(title: "Мастер престижа", description: "Выполните 1 престиж", condition: { $0.prestigeCount >= 1 }),
        Achievement(title: "Энергетический магнат", description: "Накопите 1000 энергии", condition: { $0.photonEnergy >= 1000 }),
        Achievement(title: "Улучшатель", description: "Купите первое улучшение", condition: { $0.upgrades.contains(where: { $0.level > 0 }) })
    ]
    
    @Published var offlineUpgrades: [OfflineUpgrade] = [
        OfflineUpgrade(
            name: "Квантовая стабилизация",
            description: "+10% к оффлайн доходу",
            baseCost: 60, // 1 час
            multiplier: 1.5,
            effect: { currentMultiplier in currentMultiplier * 1.1 }
        ),
        OfflineUpgrade(
            name: "Временной резонанс",
            description: "Увеличивает лимит оффлайн-времени до 48ч",
            baseCost: 720, // 12 часов
            multiplier: 2.0,
            effect: { currentMultiplier in currentMultiplier } // Не влияет на множитель, но увеличит лимит
        ),
        OfflineUpgrade(
            name: "Пространственный накопитель",
            description: "Автоматически собирает 5% оффлайн-дохода каждую минуту",
            baseCost: 1440, // 24 часа
            multiplier: 2.5,
            effect: { currentMultiplier in currentMultiplier }
        )
    ]
    
    var timer: AnyCancellable?
    private let maxParticles = 80
    private var achievementQueue: [Achievement] = []
    private var isShowingAchievement = false
    
    // Computed properties
    var offlineIncomeMultiplier: Double {
        var multiplier = 0.3 // Базовый множитель
        for upgrade in offlineUpgrades {
            if upgrade.level > 0 {
                multiplier = upgrade.effect(multiplier)
            }
        }
        return multiplier
    }
    
    var maxOfflineTime: TimeInterval {
        let baseTime: TimeInterval = 24 * 3600 // 24 часа
        // Если куплено улучшение "Временной резонанс"
        if offlineUpgrades[1].level > 0 {
            return 48 * 3600 // 48 часов
        }
        return baseTime
    }
    
    var achievementSpeedBonus: Double {
        Double(achievements.filter { $0.isUnlocked }.count) * 0.01
    }
    
    var effectiveSpeed: Double {
        min(speed + achievementSpeedBonus, maxSpeed * 1.2)
    }
    
    var tapMultiplier: Double {
        1.0 + Double(upgrades[0].level) * 0.2
    }
    
    var autoClickerSpeed: Double {
        Double(upgrades[1].level) * 0.1
    }
    
    var energyMultiplier: Double {
        1.0 + Double(upgrades[2].level) * 0.5
    }
    
    var rotationMultiplier: Double {
        1.0 + Double(upgrades[3].level) * 1.0
    }
    
    var progressToPrestige: Double {
        min(effectiveSpeed / maxSpeed, 1.0)
    }
    
    init() {
        loadGame()
        
        timer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.update()
            }
        
        // Применяем оффлайн доход при запуске
        applyOfflineEarnings()
    }
    
    // MARK: - Сохранение и загрузка
    func saveGame() {
        let defaults = UserDefaults.standard
        defaults.set(speed, forKey: "speed")
        defaults.set(maxSpeed, forKey: "maxSpeed")
        defaults.set(photonEnergy, forKey: "photonEnergy")
        defaults.set(prestigeCount, forKey: "prestigeCount")
        defaults.set(lastSaveTime, forKey: "lastSaveTime")
        defaults.set(offlineTimeBank, forKey: "offlineTimeBank")
        
        // Сохраняем улучшения
        let upgradeData = upgrades.map { [
            "level": $0.level,
            "isUnlocked": $0.isUnlocked
        ]}
        defaults.set(upgradeData, forKey: "upgrades")
        
        // Сохраняем достижения (сериализуем дату в timestamp)
        let achievementData = achievements.map { [
            "isUnlocked": $0.isUnlocked,
            "isNew": $0.isNew,
            "unlockDateTimestamp": $0.unlockDate?.timeIntervalSince1970 ?? 0.0
        ]}
        defaults.set(achievementData, forKey: "achievements")
        
        // Сохраняем оффлайн улучшения
        let offlineUpgradeData = offlineUpgrades.map { [
            "level": $0.level,
            "isUnlocked": $0.isUnlocked
        ]}
        defaults.set(offlineUpgradeData, forKey: "offlineUpgrades")
    }

    func loadGame() {
        let defaults = UserDefaults.standard
        
        speed = defaults.double(forKey: "speed")
        if speed == 0 { speed = 2.0 }
        
        maxSpeed = defaults.double(forKey: "maxSpeed")
        if maxSpeed == 0 { maxSpeed = 100.0 }
        
        photonEnergy = defaults.double(forKey: "photonEnergy")
        prestigeCount = defaults.integer(forKey: "prestigeCount")
        offlineTimeBank = defaults.double(forKey: "offlineTimeBank")
        
        if let savedTime = defaults.object(forKey: "lastSaveTime") as? Date {
            lastSaveTime = savedTime
        }
        
        // Загружаем улучшения
        if let upgradeData = defaults.array(forKey: "upgrades") as? [[String: Any]] {
            for (index, data) in upgradeData.enumerated() where index < upgrades.count {
                upgrades[index].level = data["level"] as? Int ?? 0
                upgrades[index].isUnlocked = data["isUnlocked"] as? Bool ?? false
            }
        }
        
        // Загружаем достижения
        if let achievementData = defaults.array(forKey: "achievements") as? [[String: Any]] {
            for (index, data) in achievementData.enumerated() where index < achievements.count {
                achievements[index].isUnlocked = data["isUnlocked"] as? Bool ?? false
                achievements[index].isNew = data["isNew"] as? Bool ?? false
                
                let timestamp = data["unlockDateTimestamp"] as? TimeInterval ?? 0.0
                if timestamp > 0 {
                    achievements[index].unlockDate = Date(timeIntervalSince1970: timestamp)
                } else {
                    achievements[index].unlockDate = nil
                }
            }
        }
        
        // Загружаем оффлайн улучшения
        if let offlineUpgradeData = defaults.array(forKey: "offlineUpgrades") as? [[String: Any]] {
            for (index, data) in offlineUpgradeData.enumerated() where index < offlineUpgrades.count {
                offlineUpgrades[index].level = data["level"] as? Int ?? 0
                offlineUpgrades[index].isUnlocked = data["isUnlocked"] as? Bool ?? false
            }
        }
    }
    
    // MARK: - Оффлайн доход
    func calculateOfflineEarnings() -> (energy: Double, time: TimeInterval) {
        let currentTime = Date()
        let timeAway = currentTime.timeIntervalSince(lastSaveTime)
        
        let actualTimeAway = min(timeAway, maxOfflineTime)
        
        // Добавляем время в банк
        offlineTimeBank += actualTimeAway / 60 // Конвертируем секунды в минуты
        
        // Рассчитываем заработок
        let earnings = effectiveSpeed * actualTimeAway * offlineIncomeMultiplier
        
        return (earnings, actualTimeAway)
    }
    
    func applyOfflineEarnings() {
        let result = calculateOfflineEarnings()
        lastOfflineEarnings = result.energy
        offlineTime = result.time
        
        if offlineTime > 60 {
            showOfflineReward = true
            lastSaveTime = Date()
            saveGame()
        }
    }
    
    func claimOfflineReward() {
        photonEnergy += lastOfflineEarnings
        lastOfflineEarnings = 0
        showOfflineReward = false
    }
    
    func buyOfflineUpgrade(_ upgradeId: UUID) {
        if let index = offlineUpgrades.firstIndex(where: { $0.id == upgradeId }) {
            let cost = offlineUpgrades[index].baseCost * pow(offlineUpgrades[index].multiplier, Double(offlineUpgrades[index].level))
            
            if offlineTimeBank >= cost {
                offlineTimeBank -= cost
                offlineUpgrades[index].level += 1
                offlineUpgrades[index].isUnlocked = true
                saveGame()
            }
        }
    }

    func update() {
        rotation += effectiveSpeed * 0.01 * rotationMultiplier
        photonEnergy += (effectiveSpeed * 0.05 + autoClickerSpeed) * energyMultiplier
        
        // Автокликер - добавляем скорость автоматически
        speed += autoClickerSpeed * 0.01
        
        for i in 0..<particles.count {
            particles[i].radius += 2 + effectiveSpeed * 0.2
            particles[i].opacity -= 0.02
        }
        particles.removeAll(where: { $0.opacity <= 0 })
        
        if particles.count > maxParticles {
            particles.removeFirst(particles.count - maxParticles)
        }
        
        let spawnChance = min(0.3 + effectiveSpeed * 0.01, 0.6)
        if Double.random(in: 0...1) < spawnChance {
            createParticle()
        }
        
        checkAchievements()
        
        // Показываем следующее достижение из очереди, если сейчас ничего не показывается
        if !isShowingAchievement, let nextAchievement = achievementQueue.first {
            showAchievementToast = nextAchievement
            achievementQueue.removeFirst()
            isShowingAchievement = true
            
            // Автоматически скрываем через 3 секунды
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.isShowingAchievement = false
                self?.showAchievementToast = nil
            }
        }
    }
    
    func createParticle() {
        let particleCount = effectiveSpeed > maxSpeed ? 1 : 2
        
        for _ in 0..<particleCount {
            let angle = Double.random(in: 0...(2 * .pi))
            let color = pulsarColor()
            let size = CGFloat.random(in: 3...5)
            let particle = Particle(
                angle: angle,
                radius: 0,
                opacity: 1,
                color: color,
                creationTime: Date(),
                size: size
            )
            particles.append(particle)
        }
    }
    
    func accelerate() {
        speed += 0.91 * tapMultiplier
        photonEnergy += speed * 0.5 * energyMultiplier
        
        // Виброотклик
        if settings.hapticFeedback {
            HapticManager.shared.impact(style: .light)
        }
        
        let burstCount = effectiveSpeed > maxSpeed ? 2 : 4
        for _ in 0..<burstCount {
            createParticle()
        }
    }
    
    func buyUpgrade(_ upgradeId: UUID) {
        if let index = upgrades.firstIndex(where: { $0.id == upgradeId }) {
            let cost = upgrades[index].baseCost * pow(upgrades[index].multiplier, Double(upgrades[index].level))
            
            if photonEnergy >= cost {
                photonEnergy -= cost
                upgrades[index].level += 1
                upgrades[index].isUnlocked = true
                
                // Виброотклик
                if settings.hapticFeedback {
                    HapticManager.shared.impact(style: .medium)
                }
            }
        }
    }
    
    func prestige() {
        if speed >= maxSpeed {
            let bonus = maxSpeed * 2
            photonEnergy += bonus
            speed = 0.5
            maxSpeed *= 1.5
            prestigeCount += 1
            particles.removeAll()
            
            // Виброотклик
            if settings.hapticFeedback {
                HapticManager.shared.notification(type: .success)
            }
        }
    }
    
    func checkAchievements() {
        for i in 0..<achievements.count {
            if !achievements[i].isUnlocked && achievements[i].condition(self) {
                achievements[i].isUnlocked = true
                achievements[i].isNew = true
                achievements[i].unlockDate = Date() // Добавляем дату разблокировки
                
                // Добавляем достижение в очередь для показа
                achievementQueue.append(achievements[i])
                
                // Обновляем состояние бейджа
                badgeState.hasNewAchievements = achievements.contains(where: { $0.isNew })
                badgeState.badgeCount = achievements.filter { $0.isNew }.count
                
                photonEnergy += 50
            }
        }
    }
    
    func markAchievementAsRead(_ achievementId: UUID) {
        if let index = achievements.firstIndex(where: { $0.id == achievementId }) {
            achievements[index].isNew = false
            badgeState.hasNewAchievements = achievements.contains(where: { $0.isNew })
            badgeState.badgeCount = achievements.filter { $0.isNew }.count
        }
    }
    
    func pulsarColor() -> Color {
        let t = min(effectiveSpeed / maxSpeed, 1.0)
        
        if t < 0.3 {
            let red = 0.3 + 0.7 * (t / 0.3)
            return Color(red: red, green: 0, blue: 1.0)
        } else if t < 0.6 {
            let blue = 1.0 - 0.5 * ((t - 0.3) / 0.3)
            return Color(red: 1.0, green: 0.2 * ((t - 0.3) / 0.3), blue: blue)
        } else if t < 0.8 {
            let green = 0.5 + 0.5 * ((t - 0.6) / 0.2)
            let blue = 0.5 + 0.5 * ((t - 0.6) / 0.2)
            return Color(red: 1.0, green: green, blue: blue)
        } else {
            let whiteAmount = (t - 0.8) / 0.2
            return Color(red: 1.0, green: 1.0, blue: 1.0 - 0.2 * whiteAmount)
        }
    }
}
