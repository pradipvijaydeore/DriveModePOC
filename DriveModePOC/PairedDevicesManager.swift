//
//  PairedDevicesManager.swift
//  DriveModePOC
//
//  Created by Pradip on 05/12/24.
//

import Foundation

class PairedDevicesManager: ObservableObject {
    @Published var devices: [PairedDevice] = []
    private let storageKey = "PairedDevices"
    
    // Load devices from UserDefaults
    func loadDevices() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decodedDevices = try? JSONDecoder().decode([PairedDevice].self, from: savedData) {
            devices = decodedDevices
        }
    }
    
    // Save devices to UserDefaults
    private func saveDevices() {
        if let encodedData = try? JSONEncoder().encode(devices) {
            UserDefaults.standard.set(encodedData, forKey: storageKey)
        }
    }
    
    // Add a device if it doesn't already exist
    func addDevice(name: String) {
        guard !devices.contains(where: { $0.name == name }) else { return }
        let newDevice = PairedDevice(name: name)
        devices.append(newDevice)
        saveDevices()
    }
    
    // Update a device
    func updateDevice(_ device: PairedDevice) {
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices[index] = device
        } else {
            devices.append(device)
        }
        saveDevices()
    }
    
    // Delete a device
    func deleteDevice(at offsets: IndexSet) {
        devices.remove(atOffsets: offsets)
        saveDevices()
    }
    
    // Forget a specific device
    func forgetDevice(_ device: PairedDevice) {
        devices.removeAll { $0.id == device.id }
        saveDevices()
    }
}


struct PairedDevice: Identifiable, Codable {
    let id: UUID
    var name: String
    var driveModeEnabled: Bool
    
    init(id: UUID = UUID(), name: String, driveModeEnabled: Bool = false) {
        self.id = id
        self.name = name
        self.driveModeEnabled = driveModeEnabled
    }
}
