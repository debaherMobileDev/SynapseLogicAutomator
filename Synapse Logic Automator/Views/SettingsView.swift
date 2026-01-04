//
//  SettingsView.swift
//  Synapse Logic Automator
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showingResetAlert = false
    @State private var showingAbout = false
    @State private var showCompletedTasks = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // User Stats Section
                        VStack(spacing: 16) {
                            Text("Your Statistics")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 12) {
                                StatRow(
                                    icon: "checkmark.circle.fill",
                                    title: "Tasks Completed",
                                    value: "\(viewModel.userStats.totalTasksCompleted)",
                                    color: Color(hex: "#3cc45b")
                                )
                                
                                StatRow(
                                    icon: "plus.circle.fill",
                                    title: "Tasks Created",
                                    value: "\(viewModel.userStats.totalTasksCreated)",
                                    color: Color(hex: "#fcc418")
                                )
                                
                                StatRow(
                                    icon: "flame.fill",
                                    title: "Current Streak",
                                    value: "\(viewModel.userStats.currentStreak) days",
                                    color: Color(hex: "#ff9800")
                                )
                                
                                StatRow(
                                    icon: "trophy.fill",
                                    title: "Longest Streak",
                                    value: "\(viewModel.userStats.longestStreak) days",
                                    color: Color(hex: "#fcc418")
                                )
                                
                                StatRow(
                                    icon: "percent",
                                    title: "Completion Rate",
                                    value: String(format: "%.1f%%", viewModel.userStats.completionRate),
                                    color: Color(hex: "#3cc45b")
                                )
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Preferences Section
                        VStack(spacing: 16) {
                            Text("Preferences")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 0) {
                                SettingsToggle(
                                    icon: "checkmark.circle",
                                    title: "Show Completed",
                                    subtitle: "Display completed tasks",
                                    isOn: $showCompletedTasks,
                                    color: Color(hex: "#3cc45b")
                                )
                            }
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                        
                        // Sort Preferences
                        VStack(spacing: 16) {
                            Text("Default Sort")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Picker("Sort By", selection: $viewModel.sortOption) {
                                ForEach(TaskSortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .colorScheme(.dark)
                        }
                        
                        // Actions Section
                        VStack(spacing: 16) {
                            Text("Actions")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 12) {
                                Button(action: {
                                    hasCompletedOnboarding = false
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "#fcc418"))
                                        
                                        Text("Show Onboarding")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    showingAbout = true
                                }) {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "#3cc45b"))
                                        
                                        Text("About")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    showingResetAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.red)
                                        
                                        Text("Reset All Data")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.red)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Version Info
                        VStack(spacing: 8) {
                            Text("Synapse Logic Automator")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Version 1.0.0")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 16)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#fcc418"))
                }
            }
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetAllData()
                hasCompletedOnboarding = false
            }
        } message: {
            Text("This will permanently delete all your tasks, settings, and statistics. This action cannot be undone.")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .onChange(of: showCompletedTasks) { newValue in
            viewModel.showCompletedTasks = newValue
        }
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: color))
        .padding(16)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: "#fcc418"))
                    
                    VStack(spacing: 16) {
                        Text("Synapse Logic Automator")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Your ultimate task automation companion")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 16) {
                        FeatureItem(
                            icon: "clock.fill",
                            title: "Smart Scheduling",
                            description: "Intelligent task scheduling with automated triggers"
                        )
                        
                        FeatureItem(
                            icon: "chart.bar.fill",
                            title: "Statistics",
                            description: "Track your productivity and progress"
                        )
                        
                        FeatureItem(
                            icon: "tag.fill",
                            title: "Organization",
                            description: "Organize tasks with tags and priorities"
                        )
                        
                        FeatureItem(
                            icon: "lightbulb.fill",
                            title: "Smart Suggestions",
                            description: "AI-powered productivity recommendations"
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    Text("Version 1.0.0")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 60)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#fcc418"))
                }
            }
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "#fcc418"))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

