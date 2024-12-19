//
//  DrivingDetector.swift
//  DriveModePOC
//
//  Created by Pradip on 26/11/24.
//
import CoreMotion
import SwiftUI

class DrivingDetector: ObservableObject {
    // MARK: - Properties
    private let motionActivityManager = CMMotionActivityManager()

    @Published var isDriving = false
    @Published var activity: CMMotionActivity?
    @Published var motionData: CMDeviceMotion?
    @Published var activityName: String?

    //private var activityBuffer: [CMMotionActivity] = []

    // MARK: - Start Monitoring
    func startMonitoring() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            print("Motion Activity updates are not available.")
            return
        }

        // Start Activity Updates
        beginMotionTracking()
    }

    // MARK: - Stop Monitoring
    func stopMonitoring() {
        motionActivityManager.stopActivityUpdates()
    }

    // MARK: - Motion Tracking
    private func beginMotionTracking() {
        motionActivityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self, let activity else { return }

            DispatchQueue.main.async {
                self.handleActivityUpdate(activity)
            }
        }
    }

    // MARK: - Handle Activity Update
    private func handleActivityUpdate(_ activity: CMMotionActivity) {
        let confidence = getName(confidence: activity.confidence)
        activityName = " Stationary: \(activity.stationary) \n Automotive: \(activity.automotive) \n Confidence: \(confidence)"
            print(activityName!)    }
    
    func getName(confidence: CMMotionActivityConfidence) -> String {
        switch confidence {
        case .low:
            return "low"
        case .medium:
            return "medium"
        case .high:
            return "high"
        @unknown default:
            return "default"
        }
    }
}

