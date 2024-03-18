//
//  GloveView.swift
//  test2
//
//  Created by Hayden Hubert on 1/12/24.
//
import SwiftUI

struct GloveView: View {
    @State private var termsAgreed = false
    @State private var useAppData = true // Preselect "Use data gathered by app"
    @State private var gyroscopeData: String = ""
    @State private var accelerationData: String = ""
    @State private var rotationData: String = ""
    @State private var selectionMade = false // Track if user has made a selection
    @State private var showDataEntry = false // Track if user has chosen data entry
    @State private var showingLoadingView = false // Track if loading view should be shown
    @State private var movementFrequency: Double = 0.0 // Track movement frequency
    @State private var classification: String = "" // Track classification
    @State private var showClassificationScreen = false // Track if classification screen should be shown
    @State private var showInsertTremorFrequency = false // Track if insert tremor frequency view should be shown

    // Define classification options
    let classificationOptions = ["Negligible", "Slow", "Moderate", "Rapid", "Too extreme for app measurements"]

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                if showClassificationScreen {
                    // Pass movement frequency and showClassificationScreen to ClassificationView
                    ClassificationView(showClassificationScreen: $showClassificationScreen, movementFrequency: movementFrequency)
                } else if showInsertTremorFrequency {
                    InsertTremorFrequencyView(showInsertTremorFrequency: $showInsertTremorFrequency, movementFrequency: $movementFrequency, showClassificationScreen: $showClassificationScreen)
                } else {
                    VStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.gray.opacity(0.2))
                            .overlay(
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("How would you like to enter your data?")
                                        .font(.headline)
                                        .padding(.leading)
                                    Button(action: {
                                        useAppData = true
                                        selectionMade = true
                                        // Capture movement frequency when selecting "Use data gathered by app"
                                        if useAppData {
                                            captureMovementFrequency()
                                        }
                                    }) {
                                        HStack(spacing: 10) {
                                            Image(systemName: useAppData ? "checkmark.square.fill" : "square")
                                                .foregroundColor(useAppData ? .blue : .black)
                                            Text("Use data gathered by app")
                                        }
                                    }
                                    .padding(.leading)
                                    Button(action: {
                                        useAppData = false
                                        selectionMade = true
                                    }) {
                                        HStack(spacing: 10) {
                                            Image(systemName: useAppData ? "square" : "checkmark.square.fill")
                                                .foregroundColor(useAppData ? .black : .blue)
                                            Text("Insert data")
                                        }
                                    }
                                    .padding(.leading)
                                }
                            )
                            .padding()
                        Spacer()
                        if selectionMade {
                            HStack {
                                Spacer()
                                Button(action: {
                                    if useAppData {
                                        // Simulate processing of app data
                                        simulateDataProcessing()
                                    } else {
                                        // Process inserted data
                                        withAnimation {
                                            showDataEntry = true
                                            //showingLoadingView = true
                                            showInsertTremorFrequency = true
                                        }
                                    }
                                }) {
                                    Text("Next")
                                        .padding(.horizontal)
                                        .padding(.vertical, 10)
                                        .background((!gyroscopeData.isEmpty && !accelerationData.isEmpty && !rotationData.isEmpty) ? Color.blue : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .opacity((!gyroscopeData.isEmpty && !accelerationData.isEmpty && !rotationData.isEmpty) ? 1.0 : 0.5) // Disable button if no data is entered
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
                Spacer()
            }
            .navigationBarTitle("TrackYourTremor Glove", displayMode: .inline)
            .onAppear {
                termsAgreed = true // Assume terms are agreed when the view appears
            }
            //.sheet(isPresented: $showingLoadingView) {
            //    LoadingView()
            //}
        }
    }

    // Simulate data processing
    private func simulateDataProcessing() {
        // Simulate processing time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Determine classification based on movement frequency
            if movementFrequency < 3 {
                classification = "Negligible"
            } else if movementFrequency < 5 {
                classification = "Slow"
            } else if movementFrequency < 8 {
                classification = "Moderate"
            } else if movementFrequency < 12 {
                classification = "Rapid"
            } else {
                classification = "Too extreme for app measurements"
            }

            // Update loading state
            //showingLoadingView = false

            // Show the classification screen
            showClassificationScreen = true
        }
    }
    
    // Capture movement frequency from MotionTrackingView
    private func captureMovementFrequency() {
        // Simulate capturing movement frequency from MotionTrackingView
        movementFrequency = 5.0 // Replace with actual captured frequency
    }
}


struct InsertTremorFrequencyView: View {
    @Binding var showInsertTremorFrequency: Bool
    @Binding var movementFrequency: Double
    @Binding var showClassificationScreen: Bool // Binding to toggle classification screen
    @State private var tremorFrequency: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter Tremor Frequency (Hz)", text: $tremorFrequency)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: {
                    if let frequency = Double(tremorFrequency) {
                        movementFrequency = frequency
                        showInsertTremorFrequency = false
                        showClassificationScreen = true // Show the classification screen
                    }
                }) {
                    Text("Confirm")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitle("Insert Tremor Frequency", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: // Add custom back button
                                    Button(action: {
                                        // Go back to previous screen
                                        withAnimation {
                                            showInsertTremorFrequency = false
                                        }
                                    }) {
                                        Image(systemName: "arrow.left")
                                            .foregroundColor(.blue)
                                            .padding()
                                    }
            )
        }
    }
}

struct ClassificationView: View {
    @Binding var showClassificationScreen: Bool // Binding to toggle classification screen
    let movementFrequency: Double // Movement frequency to determine classification

    var body: some View {
        VStack {
            Text("Movement Frequency: \(movementFrequency) Hz") // Display movement frequency
                .padding(.top)
                .font(.headline)

            Text("Your Classification")
                .font(.title)
                .padding()

            // Display all classifications in bubbles
            VStack(spacing: 5) {
                ForEach(getClassifications(), id: \.self) { classification in
                    Text(classification)
                        .font(.system(size: 12)) // Smaller font size
                        .padding(10)
                        .foregroundColor(.white)
                        .background(getBackgroundColor(for: classification))
                        .cornerRadius(20)
                        .padding(.horizontal, 5)
                }
            }
            .padding()

            // Rounded box with message based on classification
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.gray.opacity(0.2))
                    .padding()
                Text(getMessageForClassification())
                    .padding()
            }
            .padding()

            Spacer()
        }
        .navigationBarBackButtonHidden(true) // Hide default back button
        .navigationBarItems(leading: // Add custom back button
                                Button(action: {
                                    // Go back to previous screen
                                    withAnimation {
                                        showClassificationScreen = false
                                    }
                                }) {
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(.blue)
                                        .padding()
                                }
        )
    }

    // Function to get background color for each classification
    private func getBackgroundColor(for classification: String) -> Color {
        if classification == getClassification() {
            return Color.blue // Highlight assigned classification in blue
        } else {
            return Color.gray.opacity(0.5) // Other classifications in gray
        }
    }

    // Function to determine classification based on movement frequency
    private func getClassification() -> String {
        if movementFrequency < 3 {
            return "Negligible"
        } else if movementFrequency < 5 {
            return "Slow"
        } else if movementFrequency < 8 {
            return "Moderate"
        } else if movementFrequency < 12 {
            return "Rapid"
        } else {
            return "Too extreme for app measurements"
        }
    }

    // Function to get all classification options
    private func getClassifications() -> [String] {
        ["Negligible", "Slow", "Moderate", "Rapid", "Too extreme for app measurements"]
    }

    // Function to get message based on classification
    private func getMessageForClassification() -> String {
        switch getClassification() {
        case "Negligible":
            return "Based on your unique tremor measurement you should not add any weights to the Anti-Tremor Glove."
        case "Slow":
            return "Based on your unique tremor measurement you should add 1-2 weights to the Anti-Tremor Glove."
        case "Moderate":
            return "Based on your unique tremor measurement you should add 2-3 weights to the Anti-Tremor Glove."
        case "Rapid":
            return "Based on your unique tremor measurement you should add 4-5 weights to the Anti-Tremor Glove."
        case "Too extreme for app measurements":
            return "Please ask a doctor if the Anti Tremor Glove is optimal for your tremor. If confirmed please add 5 weights to the Anti-Tremor Glove."
        default:
            return ""
        }
    }
}
