//
//  Power_UpApp.swift
//  Power-Up WatchKit Extension
//
//  Created by Steven Miller on 8/31/21.
//

import SwiftUI

@main
struct Power_UpApp: App {
    // Business logic
    var workoutManager = HealthKitMetrics()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(workoutManager)
            }
        }
    }
}
