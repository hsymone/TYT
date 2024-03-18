//
//  MotionTrackingView.swift
//  test2
//
//  Created by Hayden Hubert on 1/12/24.
//

import SwiftUI
import CoreMotion
import Accelerate
import Combine

class MotionManager: ObservableObject {
    let motionManager = CMMotionManager()
}

class AnimationState: ObservableObject {
    @Published var isAnimating = true
}

class MotionTrackingViewModel: ObservableObject {
    @Published var gyroscopeData: String = ""
    @Published var motionData: [MotionData] = []
    @Published var rotationData: String = ""
    @Published var trackingCompleted: Bool = false
    @Published var movementFrequency: Double = 0.0
    @Published var finalMovementFrequency: Double = 0.0 // New property for final movement frequency

    func setTrackingCompleted(_ completed: Bool) {
        trackingCompleted = completed
    }
    
    func calculateMovementFrequency() {
        // Calculate movement frequency based on collected motion data
        // Assign the calculated value to finalMovementFrequency
    }
}
//STRUCT BEGINS AFTER THIS
struct MotionTrackingView: View {
    @ObservedObject var viewModel: MotionTrackingViewModel
    @EnvironmentObject var motionManager: MotionManager
    @EnvironmentObject var animationState: AnimationState
    @State private var isTimerActive = false
    @State private var elapsedTime: TimeInterval = 0.0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
                .ignoresSafeArea()
            
            VStack {
                Text("Motion Tracking View")
                    .font(.title)
                    .padding()
                
                if isTimerActive {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)
                        .padding()
                } else {
                    if animationState.isAnimating {
                        LoadingView()
                            .frame(width: 50, height: 50)
                    }
                }
                
                VStack {
                    Text("Gyroscope: \(viewModel.gyroscopeData)")
                        .font(.headline)
                        .padding()
                    
                    Text("Rotation: \(viewModel.rotationData)")
                        .font(.headline)
                        .padding()
                    
                    VStack {
                        Text("Time Left:")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Text("\(Int(60.0 - elapsedTime)) seconds")
                            .font(.headline)
                    }
                    .padding()
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            startMotionTracking()
        }
        .alert(isPresented: $isTimerActive) {
            Alert(
                title: Text("Motion Tracking Timer Complete"),
                message: Text("Motion tracking has completed."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func startMotionTracking() {
        elapsedTime = 0.0
        let timerDuration = 60.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation {
                elapsedTime += 0.1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timerDuration) {
            isTimerActive = true
            animationState.isAnimating = false
            timer?.invalidate()
            timer = nil
        }
        
        guard motionManager.motionManager.isGyroAvailable && motionManager.motionManager.isAccelerometerAvailable && motionManager.motionManager.isDeviceMotionAvailable else {
            return
        }
        
        motionManager.motionManager.gyroUpdateInterval = 0.1
        motionManager.motionManager.accelerometerUpdateInterval = 0.1
        motionManager.motionManager.startGyroUpdates(to: .main) { data, _ in
            if let gyroData = data {
                self.viewModel.gyroscopeData = "X: \(gyroData.rotationRate.x), Y: \(gyroData.rotationRate.y), Z: \(gyroData.rotationRate.z)"
            }
        }
        
        motionManager.motionManager.startDeviceMotionUpdates(to: .main) { data, _ in
            if let motionData = data {
                self.viewModel.rotationData = "Pitch: \(motionData.attitude.pitch), Roll: \(motionData.attitude.roll), Yaw: \(motionData.attitude.yaw)"
            }
        }
        
        motionManager.motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            if let accelData = data {
                let motionDataPoint = MotionData(timestamp: Date(), accelerationX: accelData.acceleration.x, accelerationY: accelData.acceleration.y, accelerationZ: accelData.acceleration.z)
                self.viewModel.motionData.append(motionDataPoint)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timerDuration) {
            self.motionManager.motionManager.stopGyroUpdates()
            self.motionManager.motionManager.stopDeviceMotionUpdates()
            self.motionManager.motionManager.stopAccelerometerUpdates()
            
            self.viewModel.setTrackingCompleted(true)
            self.viewModel.calculateMovementFrequency() // Calculate movement frequency
        }
    }
}








//MOTIONDATA

import SwiftUI

struct MotionData: Equatable {
    let timestamp: Date
    let accelerationX: Double
    let accelerationY: Double
    let accelerationZ: Double
}

extension Array where Element == MotionData {
    func dataPointsForAxis(axis: String) -> [GraphDataPoint] {
        switch axis {
        case "X":
            return self.map { GraphDataPoint(frequency: $0.accelerationX, interval: $0.timestamp.timeIntervalSince1970) }
        case "Y":
            return self.map { GraphDataPoint(frequency: $0.accelerationY, interval: $0.timestamp.timeIntervalSince1970) }
        case "Z":
            return self.map { GraphDataPoint(frequency: $0.accelerationZ, interval: $0.timestamp.timeIntervalSince1970) }
        default:
            return []
        }
    }
}

