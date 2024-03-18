//
//  ContentView.swift
//  TYTV.3
//
//  Created by Hayden Hubert on 1/31/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var motionManager = MotionManager()
    @StateObject var animationState = AnimationState()
    @StateObject var viewModel = MotionTrackingViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                ProfileEditView()
                    .environmentObject(viewModel)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            
            NavigationView {
                GraphView()
                    .environmentObject(viewModel)
            }
            .tabItem {
                Label("Graph", systemImage: "chart.bar.fill")
            }
            
            NavigationView {
                GloveView()
                    .environmentObject(viewModel)
            }
            .tabItem {
                Label("Glove", systemImage: "hand.app.fill")
            }
            
        }
        .environmentObject(motionManager)
        .environmentObject(animationState)
    }
}
