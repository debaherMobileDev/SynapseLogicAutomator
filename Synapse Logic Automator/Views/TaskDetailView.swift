//
//  TaskDetailView.swift
//  Synapse Logic Automator
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import SwiftUI

struct TaskDetailView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDeleteAlert = false
    @State private var showingEditView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Status & Priority
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Status")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: task.status.icon)
                                        .foregroundColor(Color(hex: "#3cc45b"))
                                    Text(task.status.rawValue)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("Priority")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Circle()
                                        .fill(Color(hex: task.priority.color))
                                        .frame(width: 12, height: 12)
                                    Text(task.priority.rawValue)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Title & Description
                        VStack(alignment: .leading, spacing: 16) {
                            Text(task.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            if !task.description.isEmpty {
                                Text(task.description)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Dates
                        VStack(spacing: 16) {
                            if let dueDate = task.dueDate {
                                DetailRow(
                                    icon: "calendar",
                                    title: "Due Date",
                                    value: formatDateTime(dueDate),
                                    color: Color(hex: "#fcc418")
                                )
                            }
                            
                            DetailRow(
                                icon: "clock",
                                title: "Created",
                                value: formatDateTime(task.createdDate),
                                color: Color(hex: "#3cc45b")
                            )
                            
                            if let completedDate = task.completedDate {
                                DetailRow(
                                    icon: "checkmark.circle",
                                    title: "Completed",
                                    value: formatDateTime(completedDate),
                                    color: Color(hex: "#3cc45b")
                                )
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Tags
                        if !task.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tags")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(task.tags, id: \.self) { tag in
                                            Text(tag)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color(hex: "#3cc45b").opacity(0.3))
                                                .cornerRadius(16)
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                        
                        // Automation Triggers
                        if !task.automationTriggers.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Automation Triggers")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                ForEach(task.automationTriggers) { trigger in
                                    HStack {
                                        Image(systemName: "bolt.fill")
                                            .foregroundColor(Color(hex: "#fcc418"))
                                        
                                        Text(trigger.type.displayName)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Spacer()
                                        
                                        Circle()
                                            .fill(trigger.isActive ? Color(hex: "#3cc45b") : Color.gray)
                                            .frame(width: 8, height: 8)
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                        
                        // Recurrence
                        if task.isRecurring, let rule = task.recurrenceRule {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "repeat")
                                        .foregroundColor(Color(hex: "#fcc418"))
                                    
                                    Text("Recurring Task")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                Text("\(rule.frequency.rawValue)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            if task.status != .completed {
                                Button(action: {
                                    viewModel.completeTask(task)
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Mark as Completed")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "#3e4464"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(hex: "#3cc45b"))
                                    .cornerRadius(12)
                                }
                            }
                            
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Task")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.top, 16)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Task Details")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#fcc418"))
                }
            }
        }
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteTask(task)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

