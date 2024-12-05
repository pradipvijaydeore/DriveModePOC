//
//  ContentView.swift
//  DriveModePOC
//
//  Created by Pradip on 26/11/24.
//

import CoreMotion
import SwiftUI

struct ContentView: View {
    @StateObject private var detector = DrivingDetector()
    @State private var activityHistory: [(type: String, symbol: String, time: String)] = []
    @State private var currentActivity: String?
    @State private var lastUpdateTime: Date? = nil // Track the last update time

    var body: some View {
        VStack(spacing: 20) {
            PairedDevicesView()
            VStack(spacing: 10) {
                Text("Current Activity: \(currentActivity ?? "None")")
                    .font(.headline)
            
                List(activityHistory, id: \.time) { activity in
                    HStack {
                        Text(activity.type)
                            .font(.title3)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: activity.symbol)
                            .font(.title3)
                        Text(activity.time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onAppear {
            detector.startMonitoring()
        }
        .onDisappear {
            detector.stopMonitoring()
        }
        .onReceive(detector.$activity) { newValue in
            guard let newActivity = newValue else { return }

            // Get details and current time
            let details = getActivityDetails(for: newActivity)
            let currentTime = getCurrentTime()

            // Check if enough time has passed since the last update
            if let lastUpdate = lastUpdateTime, Date().timeIntervalSince(lastUpdate) < 20 {
                return // Skip updating if less than 20 seconds have passed
            }

            // Check if the new activity differs from the last in the history
            if let lastActivity = activityHistory.first,
               lastActivity.type == details.type {
                return // Do nothing if the activity type is the same
            }

            // Update the current activity and history
            currentActivity = details.type
            activityHistory.insert((type: details.type, symbol: details.symbol, time: currentTime), at: 0)

            // Update the last update time
            lastUpdateTime = Date()
        }
    }

    private func getActivityDetails(for activity: CMMotionActivity) -> (type: String, symbol: String) {
        switch true {
        case activity.unknown:
            return ("Unknown", "questionmark.circle")
        case activity.stationary:
            return ("Stationary", "figure.stand")
        case activity.walking:
            return ("Walking", "figure.walk")
        case activity.running:
            return ("Running", "figure.run")
        case activity.automotive:
            return ("Driving", "car")
        case activity.cycling:
            return ("Cycling", "bicycle")
        default:
            return ("Unknown", "ellipsis.circle")
        }
    }

    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a" // Format for 12-hour clock with AM/PM
        return formatter.string(from: Date())
    }
}
