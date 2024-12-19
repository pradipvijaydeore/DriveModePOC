//
//  ContentView.swift
//  DriveModePOC
//
//  Created by Pradip on 26/11/24.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var detector = DrivingDetector()
    @State private var activityHistory: [ActivityHistoryEntry] = []
    @State private var currentActivity: String?
    @State private var lastUpdateTime: Date? = nil


    @StateObject private var carConnectionDetector = CarConnectionDetector(pairedDevicesManager:  PairedDevicesManager())

    var body: some View {
        NavigationView {

            VStack(spacing: 20) {
                Text("Device Motion Data")
                    .font(.title)
                
                //PairedDevicesView()
                /*Text("Paired Devices")
                List {
                    ForEach(carConnectionDetector.pairedDevicesManager.devices) { device in
                        NavigationLink(destination: DeviceDetailView(device: device, manager: carConnectionDetector.pairedDevicesManager)) {
                            Text(device.name)
                        }
                    }
                }*/
                Button("Re-Start") {
                    detector.startMonitoring()
                }
                Text("User Activity:")
                    .font(.system(size: 14)) // You can set the size to any value you prefer
                    .fontWeight(.light)
                Text("\(currentActivity ?? "None")")
                    .font(.system(size: 20)) // You can set the size to any value you prefer
                    .fontWeight(.medium)
                
                NavigationLink(destination: ActivityHistoryView(activityHistory: $activityHistory)) {
                    Text("Show History")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .onAppear {
                detector.startMonitoring()
                
                loadActivityHistory()
                carConnectionDetector.pairedDevicesManager.loadDevices()
                carConnectionDetector.startMonitoring()
            }
            .onDisappear {
                detector.stopMonitoring()
                carConnectionDetector.stopMonitoring()
            }

            .onReceive(detector.$activityName) { newValue in
                guard let newActivityName = newValue else { return }
                let currentTime = getCurrentTime()
                let newEntry = ActivityHistoryEntry(type: newActivityName, symbol: "ellipsis.circle", time: currentTime)
                currentActivity = newActivityName

                let alreadyContains = activityHistory.first?.type == newActivityName && activityHistory.first?.time == currentTime
                if !alreadyContains {
                    activityHistory.insert(newEntry, at: 0)
                    saveActivityHistory()
                }
            }
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
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: Date())
    }

    private func loadActivityHistory() {
        if let data = UserDefaults.standard.data(forKey: "ActivityHistory"),
           let savedHistory = try? JSONDecoder().decode([ActivityHistoryEntry].self, from: data) {
            activityHistory = savedHistory
        }
    }

    private func saveActivityHistory() {
        if let data = try? JSONEncoder().encode(activityHistory) {
            UserDefaults.standard.set(data, forKey: "ActivityHistory")
        }
    }
    private func clearActivityHistory() {
        if let data = try? JSONEncoder().encode(activityHistory) {
            UserDefaults.standard.set(data, forKey: "ActivityHistory")
        }
    }
}

struct ActivityHistoryView: View {
    @Binding var activityHistory: [ActivityHistoryEntry]

    var body: some View {
        List(activityHistory, id: \.time) { activity in
            HStack {
                Text(activity.type)
                    .font(.system(size: 14)) // You can set the size to any value you prefer
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: activity.symbol)
                    .font(.title3)
                Text(activity.time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Activity History")
    }
}

struct ActivityHistoryEntry: Identifiable, Codable {
    var id = UUID() // To conform to Identifiable
    var type: String
    var symbol: String
    var time: String
}
