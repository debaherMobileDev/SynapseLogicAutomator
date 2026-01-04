//
//  OnboardingView.swift
//  Synapse Logic Automator
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    @ObservedObject var viewModel: TaskViewModel
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "checkmark.circle.fill",
            title: "Welcome to Synapse Logic Automator",
            description: "Your ultimate task automation companion. Streamline your daily workflows and boost productivity.",
            color: Color(hex: "#3cc45b")
        ),
        OnboardingPage(
            icon: "clock.fill",
            title: "Smart Task Scheduling",
            description: "Schedule tasks with intelligent reminders and automated triggers based on time, location, or custom rules.",
            color: Color(hex: "#fcc418")
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "Track Your Progress",
            description: "Monitor your productivity with detailed statistics and streak tracking.",
            color: Color(hex: "#3cc45b")
        ),
        OnboardingPage(
            icon: "lightbulb.fill",
            title: "Smart Suggestions",
            description: "Get AI-powered task suggestions based on your patterns and habits for improved productivity.",
            color: Color(hex: "#fcc418")
        )
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#3e4464")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color(hex: "#fcc418") : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.top, 50)
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        Button(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "#3e4464"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "#fcc418"))
                                .cornerRadius(16)
                        }
                    } else {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "#3e4464"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "#fcc418"))
                                .cornerRadius(16)
                        }
                        
                        Button(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(page.color)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

