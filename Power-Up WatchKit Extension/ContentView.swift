//
//  ContentView.swift
//  Power-Up WatchKit Extension
//
//  Created by Steven Miller on 8/31/21.
//

import SwiftUI

struct GreenButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(.green))
            .foregroundColor(.black)
            .clipShape(Capsule())
    }
}

struct ContentView: View {
    // Get the business logic from the environment
    @EnvironmentObject var workoutManager: HealthKitMetrics
    @State var showWorkoutView = false
    
    var body: some View {
        VStack {
            NavigationLink(destination: WorkoutView(), isActive:$showWorkoutView) {
                Text("Show WorkoutView")
            }
            
            // Replace this button with NavigationLink+buttonStyle
            Button("Begin Workout", action: {
                workoutManager.startWorkout()
                print("Begin Workout Button Pressed")
                self.showWorkoutView = true
            })
                .disabled(workoutManager.workoutInProgress == true)
                .buttonStyle(GreenButton())
        }
        .frame(height: 200)
        .padding()
        .onAppear() {
            // Moved HealthKit store authorization to Power_UpApp to avoid repeat calls
            print("ContentView onAppear - Workout in Progress: \(workoutManager.workoutInProgress)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
