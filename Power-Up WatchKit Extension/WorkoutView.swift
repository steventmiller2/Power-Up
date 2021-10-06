//
//  WorkoutView.swift
//  Power-Up WatchKit Extension
//
//  Created by brandon on 10/3/21.
//

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var workoutManager: HealthKitMetrics
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack() {
            Text("Workout in Progress: \(workoutManager.workoutInProgress)")
            Text("Heart Rate: \(workoutManager.heartrate)")
            Text("Pace: \(workoutManager.pace)")
            Button("End Workout", action: {
                workoutManager.endWorkout()
                print("End Workout Button Pressed")
                self.presentationMode.wrappedValue.dismiss()
            }).disabled(workoutManager.workoutInProgress == false)
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
    }
}
