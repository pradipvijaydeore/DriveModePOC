//
//  CarConnectionView.swift
//  DriveModePOC
//
//  Created by Pradip on 05/12/24.
//

import AVFoundation

class CarConnectionDetector: ObservableObject {
    @Published var connectedDeviceName: String = "No Device Connected"
    @Published var isConnected: Bool = false
    
    private var notificationObserver: Any?
    let pairedDevicesManager: PairedDevicesManager
    
    init(pairedDevicesManager: PairedDevicesManager) {
        self.pairedDevicesManager = pairedDevicesManager
    }
    
    func startMonitoring() {
        configureAudioSession()
        notificationObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleRouteChange(notification: notification)
        }
        updateCurrentRoute()
    }
    
    func stopMonitoring() {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func handleRouteChange(notification: Notification) {
        updateCurrentRoute()
    }
    
    private func updateCurrentRoute() {
        let session = AVAudioSession.sharedInstance()
        let currentRoute = session.currentRoute
        
        for output in currentRoute.outputs {
            print("Port Name: \(output.portName), Port Type: \(output.portType)")
            if output.portType == .bluetoothA2DP || output.portType == .carAudio || output.portType == .usbAudio {
                DispatchQueue.main.async {
                    self.connectedDeviceName = output.portName
                    self.isConnected = true
                    
                    // Save the connected device
                    self.pairedDevicesManager.addDevice(name: output.portName)
                }
                return
            }
        }
        
        DispatchQueue.main.async {
            self.connectedDeviceName = "No Device Connected"
            self.isConnected = false
        }
    }
}
