//
//  DataService.swift
//  Synapse Logic Automator
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var tasks: [Task] = []
    @Published var userStats: UserStats = UserStats()
    
    private let tasksKey = "synapse_tasks"
    private let statsKey = "synapse_stats"
    
    private init() {
        loadData()
        updateProductivityScore()
    }
    
    // MARK: - Task Management
    func addTask(_ task: Task) {
        tasks.append(task)
        userStats.totalTasksCreated += 1
        updateStats()
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            let oldStatus = tasks[index].status
            tasks[index] = task
            
            // Update stats if status changed to completed
            if oldStatus != .completed && task.status == .completed {
                userStats.totalTasksCompleted += 1
                task.tags.forEach { tag in
                    userStats.mostUsedTags[tag, default: 0] += 1
                }
                updateStreak()
                
                // Calculate average completion time
                if let createdDate = tasks[index].createdDate as Date?,
                   let completedDate = task.completedDate {
                    let completionTime = completedDate.timeIntervalSince(createdDate)
                    let totalTime = userStats.averageCompletionTime * Double(userStats.totalTasksCompleted - 1)
                    userStats.averageCompletionTime = (totalTime + completionTime) / Double(userStats.totalTasksCompleted)
                }
            } else if oldStatus != .cancelled && task.status == .cancelled {
                userStats.totalTasksCancelled += 1
            }
            
            updateStats()
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }
    
    func completeTask(_ task: Task) {
        var updatedTask = task
        updatedTask.status = .completed
        updatedTask.completedDate = Date()
        updateTask(updatedTask)
    }
    
    // MARK: - Filtering & Sorting
    func getTasks(by status: TaskStatus) -> [Task] {
        return tasks.filter { $0.status == status }
    }
    
    func getTasks(by priority: TaskPriority) -> [Task] {
        return tasks.filter { $0.priority == priority }
    }
    
    func getTasksDueToday() -> [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate >= today && dueDate < tomorrow && task.status != .completed
        }
    }
    
    func getUpcomingTasks() -> [Task] {
        let now = Date()
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate > now && task.status != .completed
        }.sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
    }
    
    func getOverdueTasks() -> [Task] {
        let now = Date()
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < now && task.status != .completed
        }
    }
    
    func searchTasks(query: String) -> [Task] {
        guard !query.isEmpty else { return tasks }
        let lowercasedQuery = query.lowercased()
        return tasks.filter { task in
            task.title.lowercased().contains(lowercasedQuery) ||
            task.description.lowercased().contains(lowercasedQuery) ||
            task.tags.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
    
    // MARK: - Smart Suggestions
    func getSmartSuggestions() -> [String] {
        var suggestions: [String] = []
        
        // Suggest based on time of day
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 6 && hour < 9 {
            suggestions.append("Morning routine check")
            suggestions.append("Review today's priorities")
        } else if hour >= 12 && hour < 14 {
            suggestions.append("Lunch break")
            suggestions.append("Midday progress review")
        } else if hour >= 17 && hour < 20 {
            suggestions.append("Evening planning")
            suggestions.append("Tomorrow's preparation")
        }
        
        // Suggest based on most used tags
        let topTags = userStats.mostUsedTags.sorted { $0.value > $1.value }.prefix(3)
        for (tag, _) in topTags {
            suggestions.append("New \(tag) task")
        }
        
        // Suggest based on overdue tasks
        if !getOverdueTasks().isEmpty {
            suggestions.append("Review overdue tasks")
        }
        
        return suggestions
    }
    
    // MARK: - Stats Management
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = userStats.lastActivityDate {
            let lastActivityDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastActivityDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                userStats.currentStreak += 1
                if userStats.currentStreak > userStats.longestStreak {
                    userStats.longestStreak = userStats.currentStreak
                }
            } else if daysDifference > 1 {
                userStats.currentStreak = 1
            }
        } else {
            userStats.currentStreak = 1
            userStats.longestStreak = 1
        }
        
        userStats.lastActivityDate = Date()
    }
    
    private func updateProductivityScore() {
        let completionRate = userStats.completionRate
        let streakBonus = Double(userStats.currentStreak) * 2.0
        let efficiencyBonus = userStats.averageCompletionTime > 0 ? 10.0 : 0.0
        
        userStats.productivityScore = min(100, completionRate + streakBonus + efficiencyBonus)
    }
    
    private func updateStats() {
        updateProductivityScore()
        saveStats()
    }
    
    // MARK: - Persistence
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(userStats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
    }
    
    private func loadStats() {
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(UserStats.self, from: data) {
            userStats = decoded
        }
    }
    
    private func loadData() {
        loadTasks()
        loadStats()
    }
    
    // MARK: - Reset
    func resetAllData() {
        tasks.removeAll()
        userStats = UserStats()
        UserDefaults.standard.removeObject(forKey: tasksKey)
        UserDefaults.standard.removeObject(forKey: statsKey)
    }
}

