//
//  DashboardView.swift
//  Synapse Logic Automator
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingTaskCreation = false
    @State private var showingSettings = false
    @State private var selectedTask: Task?
    @State private var showingTaskDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Stats
                        StatsHeaderView(viewModel: viewModel)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Smart Suggestions
                        if !viewModel.getSmartSuggestions().isEmpty {
                            SmartSuggestionsView(viewModel: viewModel, showingTaskCreation: $showingTaskCreation)
                                .padding(.horizontal)
                        }
                        
                        // Quick Filters
                        QuickFiltersView(viewModel: viewModel)
                            .padding(.horizontal)
                        
                        // Tasks List
                        TasksListView(
                            viewModel: viewModel,
                            selectedTask: $selectedTask,
                            showingTaskDetail: $showingTaskDetail
                        )
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 100)
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingTaskCreation = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color(hex: "#3e4464"))
                                .frame(width: 60, height: 60)
                                .background(Color(hex: "#fcc418"))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Synapse Logic")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color(hex: "#fcc418"))
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Search action
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "#fcc418"))
                    }
                }
            }
        }
        .sheet(isPresented: $showingTaskCreation) {
            TaskCreationView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task, viewModel: viewModel)
        }
    }
}

struct StatsHeaderView: View {
    @ObservedObject var viewModel: TaskViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Productivity Score
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Productivity Score")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(viewModel.userStats.productivityScore))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("/100")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: viewModel.userStats.productivityScore / 100,
                    color: Color(hex: "#3cc45b")
                )
                .frame(width: 80, height: 80)
            }
            .padding(20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            
            // Quick Stats
            HStack(spacing: 12) {
                StatCard(
                    title: "Today",
                    value: "\(viewModel.todayTasksCount)",
                    icon: "calendar.circle.fill",
                    color: Color(hex: "#fcc418")
                )
                
                StatCard(
                    title: "Pending",
                    value: "\(viewModel.pendingTasksCount)",
                    icon: "circle.fill",
                    color: Color(hex: "#3cc45b")
                )
                
                StatCard(
                    title: "Overdue",
                    value: "\(viewModel.overdueTasksCount)",
                    icon: "exclamationmark.circle.fill",
                    color: Color(hex: "#f44336")
                )
            }
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct SmartSuggestionsView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Binding var showingTaskCreation: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(hex: "#fcc418"))
                
                Text("Smart Suggestions")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.getSmartSuggestions().prefix(5), id: \.self) { suggestion in
                        Button(action: {
                            showingTaskCreation = true
                        }) {
                            Text(suggestion)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(hex: "#fcc418").opacity(0.2))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(hex: "#fcc418"), lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct QuickFiltersView: View {
    @ObservedObject var viewModel: TaskViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        withAnimation {
                            viewModel.selectedFilter = filter
                        }
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? Color(hex: "#3e4464") : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color(hex: "#fcc418") : Color.white.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct TasksListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Binding var selectedTask: Task?
    @Binding var showingTaskDetail: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tasks")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.filteredTasks.count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            if viewModel.filteredTasks.isEmpty {
                EmptyStateView()
            } else {
                ForEach(viewModel.filteredTasks) { task in
                    TaskRowView(task: task, viewModel: viewModel)
                        .onTapGesture {
                            selectedTask = task
                        }
                }
            }
        }
    }
}

struct TaskRowView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                viewModel.toggleTaskCompletion(task)
            }) {
                Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(task.status == .completed ? Color(hex: "#3cc45b") : .white.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .strikethrough(task.status == .completed)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    if let dueDate = task.dueDate {
                        Label(formatDate(dueDate), systemImage: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    if !task.tags.isEmpty {
                        Label(task.tags.first ?? "", systemImage: "tag")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            Spacer()
            
            Circle()
                .fill(Color(hex: task.priority.color))
                .frame(width: 12, height: 12)
        }
        .padding(16)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No tasks found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Tap the + button to create your first task")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

