//
//  TaskCreationView.swift
//  Synapse Logic Automator
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import SwiftUI

struct TaskCreationView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedPriority: TaskPriority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    @State private var tags: [String] = []
    @State private var currentTag = ""
    @State private var syncWithCalendar = false
    @State private var isRecurring = false
    @State private var selectedFrequency: RecurrenceFrequency = .daily
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Title")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            TextField("Enter task title", text: $title)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            TextEditor(text: $description)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        // Priority
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            HStack(spacing: 12) {
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    PriorityButton(
                                        priority: priority,
                                        isSelected: selectedPriority == priority
                                    ) {
                                        selectedPriority = priority
                                    }
                                }
                            }
                        }
                        
                        // Due Date
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $hasDueDate) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color(hex: "#fcc418"))
                                    Text("Due Date")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#3cc45b")))
                            
                            if hasDueDate {
                                DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .colorScheme(.dark)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Reminder
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $hasReminder) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(Color(hex: "#fcc418"))
                                    Text("Reminder")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#3cc45b")))
                            
                            if hasReminder {
                                DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .colorScheme(.dark)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Recurring Task
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $isRecurring) {
                                HStack {
                                    Image(systemName: "repeat")
                                        .foregroundColor(Color(hex: "#fcc418"))
                                    Text("Recurring Task")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#3cc45b")))
                            
                            if isRecurring {
                                Picker("Frequency", selection: $selectedFrequency) {
                                    ForEach(RecurrenceFrequency.allCases, id: \.self) { frequency in
                                        Text(frequency.rawValue).tag(frequency)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .colorScheme(.dark)
                            }
                        }
                        
                        // Tags
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tags")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            HStack {
                                TextField("Add tag", text: $currentTag)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .onSubmit {
                                        addTag()
                                    }
                                
                                Button(action: addTag) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Color(hex: "#3cc45b"))
                                }
                            }
                            
                            if !tags.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(tags, id: \.self) { tag in
                                            TagView(tag: tag) {
                                                tags.removeAll { $0 == tag }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Create Button
                        Button(action: createTask) {
                            Text("Create Task")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "#3e4464"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(title.isEmpty ? Color.gray : Color(hex: "#fcc418"))
                                .cornerRadius(16)
                        }
                        .disabled(title.isEmpty)
                        .padding(.top, 16)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Task")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#fcc418"))
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = currentTag.trimmingCharacters(in: .whitespaces)
        guard !trimmedTag.isEmpty && !tags.contains(trimmedTag) else { return }
        tags.append(trimmedTag)
        currentTag = ""
    }
    
    private func createTask() {
        var schedule: TaskSchedule?
        if hasReminder {
            schedule = TaskSchedule(alertDate: reminderDate)
        }
        
        var recurrenceRule: RecurrenceRule?
        if isRecurring {
            recurrenceRule = RecurrenceRule(frequency: selectedFrequency)
        }
        
        viewModel.createTask(
            title: title,
            description: description,
            priority: selectedPriority,
            dueDate: hasDueDate ? dueDate : nil,
            tags: tags,
            schedule: schedule,
            isRecurring: isRecurring,
            recurrenceRule: recurrenceRule,
            syncWithCalendar: syncWithCalendar
        )
        
        dismiss()
    }
}

struct PriorityButton: View {
    let priority: TaskPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: priority.color))
                    .frame(width: 20, height: 20)
                
                Text(priority.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(tag)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: "#3cc45b").opacity(0.3))
        .cornerRadius(16)
    }
}

