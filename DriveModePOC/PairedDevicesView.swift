//
//  PairedDevicesView.swift
//  DriveModePOC
//
//  Created by Pradip on 05/12/24.
//
import SwiftUI

struct PairedDevicesView: View {
    @StateObject private var carConnectionDetector = CarConnectionDetector(pairedDevicesManager:  PairedDevicesManager())
    
    init() {
        let manager = PairedDevicesManager()
        _carConnectionDetector = StateObject(wrappedValue: CarConnectionDetector(pairedDevicesManager: manager))
    }
    
    var body: some View {
        Text("Paired Devices")
        NavigationView {
            List {
                ForEach(carConnectionDetector.pairedDevicesManager.devices) { device in
                    NavigationLink(destination: DeviceDetailView(device: device, manager: carConnectionDetector.pairedDevicesManager)) {
                        Text(device.name)
                    }
                }
            }
            .onAppear {
                carConnectionDetector.pairedDevicesManager.loadDevices()
                carConnectionDetector.startMonitoring()
            }
            .onDisappear {
                carConnectionDetector.stopMonitoring()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
