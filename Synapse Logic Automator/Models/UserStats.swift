//
//  UserStats.swift
//  Synapse Logic Automator
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import Foundation

struct UserStats: Codable {
    var totalTasksCreated: Int
    var totalTasksCompleted: Int
    var totalTasksCancelled: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?
    var productivityScore: Double
    var mostUsedTags: [String: Int]
    var averageCompletionTime: TimeInterval
    
    init(
        totalTasksCreated: Int = 0,
        totalTasksCompleted: Int = 0,
        totalTasksCancelled: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastActivityDate: Date? = nil,
        productivityScore: Double = 0.0,
        mostUsedTags: [String: Int] = [:],
        averageCompletionTime: TimeInterval = 0
    ) {
        self.totalTasksCreated = totalTasksCreated
        self.totalTasksCompleted = totalTasksCompleted
        self.totalTasksCancelled = totalTasksCancelled
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActivityDate = lastActivityDate
        self.productivityScore = productivityScore
        self.mostUsedTags = mostUsedTags
        self.averageCompletionTime = averageCompletionTime
    }
    
    var completionRate: Double {
        guard totalTasksCreated > 0 else { return 0 }
        return Double(totalTasksCompleted) / Double(totalTasksCreated) * 100
    }
}

