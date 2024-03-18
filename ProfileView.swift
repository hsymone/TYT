//
//  ProfileView.swift
//  test2
//
//  Created by Hayden Hubert on 1/12/24.
//

import SwiftUI
import SwiftData
import CoreMotion
import AuthenticationServices
import Charts
import UIKit
import Combine

struct ProfileEditView: View {
    @State private var username = "John Doe"
    @State private var profileImage: Image?
    @State private var selectedConditionIndex = 0
    @State private var conditions = ["Parkinson's Disease", "Essential Tremor", "Other"]
    @State private var isImagePickerPresented = false
    @State private var isEditMode = false
    @State private var isTracking = false
    @State private var showTrackingAlert = false
    @State private var isMotionTrackingViewPresented = false
    @State private var selectedImage: UIImage?
    @State private var isImageVerified = false
    @EnvironmentObject private var motionManager: MotionManager
    @EnvironmentObject private var animationState: AnimationState
    @EnvironmentObject private var motionTrackingViewModel: MotionTrackingViewModel
    @State private var movementFrequency: Double = 0.0 // New state for movement frequency
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    // Circular profile picture
                    Button(action: {
                        if isEditMode {
                            isImagePickerPresented.toggle()
                        }
                    }) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80) // Adjust size as needed
                                .clipShape(Circle()) // Make the image circular
                                .padding()
                        } else {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 80, height: 80) // Adjust size as needed
                                .padding()
                        }
                    }
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(selectedImage: $selectedImage)
                    }
                    
                    VStack(alignment: .leading) {
                        TextField("Enter your name", text: $username)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .disabled(!isEditMode)
                            .onTapGesture {
                                if !isEditMode {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                        
                        if isEditMode {
                            Picker("", selection: $selectedConditionIndex) {
                                ForEach(0..<conditions.count, id: \.self) { index in
                                    Text(conditions[index]).tag(index)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        } else {
                            Text(conditions[selectedConditionIndex])
                                .padding(.top, 5)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                }
                
                // Scroll view for acceleration data
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Your Tremor Data")
                            .font(.title)
                            .padding(.leading)
                        
                        VStack {
                            Text("Acceleration Data (X-axis): ")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            
                            Text("Acceleration Data (Y-axis): ")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            
                            Text("Acceleration Data (Z-axis): ")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            
                            Text("Movement Frequency: \(movementFrequency) Hz") // Display movement frequency
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showTrackingAlert.toggle()
                    }
                }) {
                    Text("Start Tracking My Tremor")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .alert(isPresented: $showTrackingAlert) {
                    Alert(
                        title: Text("Please extend your arm."),
                        message: Text("If you are operating from your phone, firmly grip your phone so as not to drop it while the tremor is being measured. The measurement will take one minute. Please allow TrackYourTremor access to the __________. Select Start to begin."),
                        primaryButton: .default(Text("Start"), action: {
                            withAnimation {
                                isMotionTrackingViewPresented.toggle()
                            }
                        }),
                        secondaryButton: .cancel()
                    )
                }
            }
            .navigationBarItems(trailing:
                                    Button(action: {
                isEditMode.toggle()
            }) {
                Text(isEditMode ? "Done" : "Edit Personal Information")
                    .padding()
            }
            )
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .sheet(isPresented: $isMotionTrackingViewPresented) {
                MotionTrackingView(viewModel: motionTrackingViewModel)
                    .environmentObject(motionManager)
                    .environmentObject(animationState)
                    .environmentObject(motionTrackingViewModel)
                    .onReceive(motionTrackingViewModel.$finalMovementFrequency) { newFrequency in
                        movementFrequency = newFrequency
                    }            }
        }
    }
}
