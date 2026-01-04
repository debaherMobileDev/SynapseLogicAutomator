//
//  Task.swift
//  Synapse Logic Automator
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import Foundation
import CoreLocation

// MARK: - Task Model
struct Task: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var description: String
    var priority: TaskPriority
    var status: TaskStatus
    var createdDate: Date
    var dueDate: Date?
    var completedDate: Date?
    var tags: [String]
    var automationTriggers: [AutomationTrigger]
    var schedule: TaskSchedule?
    var isRecurring: Bool
    var recurrenceRule: RecurrenceRule?
    var calendarEventId: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        status: TaskStatus = .pending,
        createdDate: Date = Date(),
        dueDate: Date? = nil,
        completedDate: Date? = nil,
        tags: [String] = [],
        automationTriggers: [AutomationTrigger] = [],
        schedule: TaskSchedule? = nil,
        isRecurring: Bool = false,
        recurrenceRule: RecurrenceRule? = nil,
        calendarEventId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.createdDate = createdDate
        self.dueDate = dueDate
        self.completedDate = completedDate
        self.tags = tags
        self.automationTriggers = automationTriggers
        self.schedule = schedule
        self.isRecurring = isRecurring
        self.recurrenceRule = recurrenceRule
        self.calendarEventId = calendarEventId
    }
}

// MARK: - Task Priority
enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var color: String {
        switch self {
        case .low: return "#3cc45b"
        case .medium: return "#fcc418"
        case .high: return "#ff9800"
        case .urgent: return "#f44336"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .urgent: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}

// MARK: - Task Status
enum TaskStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
    
    var icon: String {
        switch self {
        case .pending: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
}

// MARK: - Automation Trigger
struct AutomationTrigger: Identifiable, Codable, Equatable {
    var id: UUID
    var type: TriggerType
    var isActive: Bool
    
    init(id: UUID = UUID(), type: TriggerType, isActive: Bool = true) {
        self.id = id
        self.type = type
        self.isActive = isActive
    }
}

enum TriggerType: Codable, Equatable {
    case time(TimeBasedTrigger)
    case location(LocationBasedTrigger)
    case custom(CustomTrigger)
    
    var displayName: String {
        switch self {
        case .time: return "Time-based"
        case .location: return "Location-based"
        case .custom: return "Custom Rule"
        }
    }
}

// MARK: - Time Based Trigger
struct TimeBasedTrigger: Codable, Equatable {
    var triggerDate: Date
    var repeatInterval: TimeInterval?
    
    init(triggerDate: Date, repeatInterval: TimeInterval? = nil) {
        self.triggerDate = triggerDate
        self.repeatInterval = repeatInterval
    }
}

// MARK: - Location Based Trigger
struct LocationBasedTrigger: Codable, Equatable {
    var latitude: Double
    var longitude: Double
    var radius: Double
    var triggerOnEntry: Bool
    var triggerOnExit: Bool
    var locationName: String
    
    init(
        latitude: Double,
        longitude: Double,
        radius: Double = 100,
        triggerOnEntry: Bool = true,
        triggerOnExit: Bool = false,
        locationName: String
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.triggerOnEntry = triggerOnEntry
        self.triggerOnExit = triggerOnExit
        self.locationName = locationName
    }
}

// MARK: - Custom Trigger
struct CustomTrigger: Codable, Equatable {
    var ruleName: String
    var condition: String
    
    init(ruleName: String, condition: String) {
        self.ruleName = ruleName
        self.condition = condition
    }
}

// MARK: - Task Schedule
struct TaskSchedule: Codable, Equatable {
    var alertDate: Date
    var reminderMinutesBefore: Int
    var hasNotification: Bool
    
    init(alertDate: Date, reminderMinutesBefore: Int = 15, hasNotification: Bool = true) {
        self.alertDate = alertDate
        self.reminderMinutesBefore = reminderMinutesBefore
        self.hasNotification = hasNotification
    }
}

// MARK: - Recurrence Rule
struct RecurrenceRule: Codable, Equatable {
    var frequency: RecurrenceFrequency
    var interval: Int
    var endDate: Date?
    
    init(frequency: RecurrenceFrequency, interval: Int = 1, endDate: Date? = nil) {
        self.frequency = frequency
        self.interval = interval
        self.endDate = endDate
    }
}

enum RecurrenceFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

