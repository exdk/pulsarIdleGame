//
//  NumberFormatterUtil.swift
//  pulsarIdleGame
//
//  Created by Виктор Юнусов on 13.09.2025.
//


//
//  NumberFormatter.swift
//  pulsarIdleGame
//
//  Created by Виктор Юнусов on 14.09.2025.
//

import Foundation

struct NumberFormatterUtil {
    static func formatNumber(_ number: Double) -> String {
        let absNumber = abs(number)
        
        if absNumber >= 1e18 {
            return String(format: "%.2fNN", number / 1e18)
        } else if absNumber >= 1e15 {
            return String(format: "%.2fTg", number / 1e15)
        } else if absNumber >= 1e12 {
            return String(format: "%.2fT", number / 1e12)
        } else if absNumber >= 1e9 {
            return String(format: "%.2fB", number / 1e9)
        } else if absNumber >= 1e6 {
            return String(format: "%.2fM", number / 1e6)
        } else if absNumber >= 1e3 {
            return String(format: "%.2fK", number / 1e3)
        } else if absNumber >= 1 {
            return String(format: "%.1f", number)
        } else if absNumber >= 0.001 {
            return String(format: "%.4f", number)
        } else {
            return String(format: "%.1e", number)
        }
    }
    
    static func formatInt(_ number: Int) -> String {
        return formatNumber(Double(number))
    }
}