//
//  Power_UpApp.swift
//  Power-Up WatchKit Extension
//
//  Created by Steven Miller on 8/31/21.
//

import SwiftUI

@main
struct Power_UpApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
