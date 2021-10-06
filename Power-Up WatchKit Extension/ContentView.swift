//
//  ContentView.swift
//  Power-Up WatchKit Extension
//
//  Created by Steven Miller on 8/31/21.
//

import SwiftUI

struct ContentView: View {
    // Get the business logic from the environment.
    @EnvironmentObject var workoutSession: HealthKitMetrics
    
    // Managing workout state
    @State var workoutInProgress = false
    
    var body: some View {
        Text("Beginning Workout!")
            .padding()
            .onAppear() {
                // Request HealthKit store authorization.
                self.workoutSession.authorizeHealthKit()
                workoutInProgress = true
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
