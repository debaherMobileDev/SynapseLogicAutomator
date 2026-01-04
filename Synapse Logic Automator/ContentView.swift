//
//  ContentView.swift
//  Synapse Logic Automator
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var viewModel = TaskViewModel()
    
    var body: some View {
        if hasCompletedOnboarding {
            DashboardView(viewModel: viewModel)
        } else {
            OnboardingView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
