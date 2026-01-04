//
//  TaskViewModel.swift
//  Synapse Logic Automator
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import Foundation
import Combine
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var userStats: UserStats = UserStats()
    @Published var searchQuery: String = ""
    @Published var selectedFilter: TaskFilter = .all
    @Published var sortOption: TaskSortOption = .dueDate
    @Published var showCompletedTasks: Bool = false
    
    private let dataService = DataService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataService.$tasks
            .receive(on: DispatchQueue.main)
            .assign(to: &$tasks)
        
        dataService.$userStats
            .receive(on: DispatchQueue.main)
            .assign(to: &$userStats)
    }
    
    // MARK: - Task Management
    func createTask(
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        tags: [String] = [],
        schedule: TaskSchedule? = nil,
        automationTriggers: [AutomationTrigger] = [],
        isRecurring: Bool = false,
        recurrenceRule: RecurrenceRule? = nil,
        syncWithCalendar: Bool = false
    ) {
        let task = Task(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate,
            tags: tags,
            automationTriggers: automationTriggers,
            schedule: schedule,
            isRecurring: isRecurring,
            recurrenceRule: recurrenceRule
        )
        
        dataService.addTask(task)
    }
    
    func updateTask(_ task: Task) {
        dataService.updateTask(task)
    }
    
    func deleteTask(_ task: Task) {
        dataService.deleteTask(task)
    }
    
    func completeTask(_ task: Task) {
        dataService.completeTask(task)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        if task.status == .completed {
            updatedTask.status = .pending
            updatedTask.completedDate = nil
        } else {
            updatedTask.status = .completed
            updatedTask.completedDate = Date()
        }
        updateTask(updatedTask)
    }
    
    // MARK: - Filtering & Sorting
    var filteredTasks: [Task] {
        var filtered = tasks
        
        // Apply search filter
        if !searchQuery.isEmpty {
            filtered = dataService.searchTasks(query: searchQuery)
        }
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            if !showCompletedTasks {
                filtered = filtered.filter { $0.status != .completed }
            }
        case .pending:
            filtered = filtered.filter { $0.status == .pending }
        case .inProgress:
            filtered = filtered.filter { $0.status == .inProgress }
        case .completed:
            filtered = filtered.filter { $0.status == .completed }
        case .today:
            filtered = dataService.getTasksDueToday()
        case .upcoming:
            filtered = dataService.getUpcomingTasks()
        case .overdue:
            filtered = dataService.getOverdueTasks()
        case .highPriority:
            filtered = filtered.filter { $0.priority == .high || $0.priority == .urgent }
        }
        
        // Apply sorting
        return sortTasks(filtered)
    }
    
    private func sortTasks(_ tasks: [Task]) -> [Task] {
        switch sortOption {
        case .dueDate:
            return tasks.sorted { task1, task2 in
                guard let date1 = task1.dueDate, let date2 = task2.dueDate else {
                    return task1.dueDate != nil
                }
                return date1 < date2
            }
        case .priority:
            return tasks.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
        case .createdDate:
            return tasks.sorted { $0.createdDate > $1.createdDate }
        case .title:
            return tasks.sorted { $0.title.lowercased() < $1.title.lowercased() }
        }
    }
    
    // MARK: - Smart Suggestions
    func getSmartSuggestions() -> [String] {
        return dataService.getSmartSuggestions()
    }
    
    // MARK: - Statistics
    var todayTasksCount: Int {
        dataService.getTasksDueToday().count
    }
    
    var overdueTasksCount: Int {
        dataService.getOverdueTasks().count
    }
    
    var pendingTasksCount: Int {
        tasks.filter { $0.status == .pending }.count
    }
    
    var completedTasksCount: Int {
        tasks.filter { $0.status == .completed }.count
    }
    
    // MARK: - Reset
    func resetAllData() {
        dataService.resetAllData()
    }
}

// MARK: - Supporting Enums
enum TaskFilter: String, CaseIterable {
    case all = "All"
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case today = "Today"
    case upcoming = "Upcoming"
    case overdue = "Overdue"
    case highPriority = "High Priority"
}

enum TaskSortOption: String, CaseIterable {
    case dueDate = "Due Date"
    case priority = "Priority"
    case createdDate = "Created Date"
    case title = "Title"
}

