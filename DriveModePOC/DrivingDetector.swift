//
//  DrivingDetector.swift
//  DriveModePOC
//
//  Created by Pradip on 26/11/24.
//
import CoreMotion
import SwiftUI

class DrivingDetector: ObservableObject {
    private let motionActivityManager = CMMotionActivityManager()
    @Published var isDriving = false
    @Published var activity: CMMotionActivity?
    
    func startMonitoring() {
        
        checkUSBConnection()
        
        guard CMMotionActivityManager.isActivityAvailable() else {
            return
        }
        motionActivityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self else { return }
            guard let activity else { return }
            DispatchQueue.main.async {
                self.activity = activity
                self.isDriving = activity.automotive
            }
        }
    }
    
    func stopMonitoring() {
        motionActivityManager.stopActivityUpdates()
    }
    
    func checkDeviceStatus() {
        // Check if user is driving
       // checkIfUserIsDriving()
        
        // Check Bluetooth connection
       // checkBluetoothConnection()
        
        // Check USB connection
        checkUSBConnection()
    }
    func checkUSBConnection() {
        let device = UIDevice.current
        if device.batteryState == .charging {
            print("Device is connected to power (could be USB)")
        } else {
            print("Device is not charging")
        }
    }
}
