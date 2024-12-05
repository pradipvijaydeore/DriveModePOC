//
//  USBAccessoryChecker.swift
//  DriveModePOC
//
//  Created by Pradip on 04/12/24.
//

import Foundation
import ExternalAccessory

class USBAccessoryChecker: ObservableObject {
    @Published var isAccessoryConnected: Bool = false

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessoryDidConnect),
            name: .EAAccessoryDidConnect,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessoryDidDisconnect),
            name: .EAAccessoryDidDisconnect,
            object: nil
        )
        EAAccessoryManager.shared().registerForLocalNotifications()
        updateAccessoryStatus()
    }

    @objc private func accessoryDidConnect() {
        updateAccessoryStatus()
    }

    @objc private func accessoryDidDisconnect() {
        updateAccessoryStatus()
    }

    private func updateAccessoryStatus() {
        let connectedAccessories = EAAccessoryManager.shared().connectedAccessories
        isAccessoryConnected = !connectedAccessories.isEmpty
        
        // Iterate through the connected accessories and access their properties
        for accessory in connectedAccessories {
            // Access various properties of the connected accessory
            let firmwareRevision = accessory.firmwareRevision
            print("Firmware Revision: \(firmwareRevision)")
            let hardwareRevision = accessory.hardwareRevision
            print("Hardware Revision: \(hardwareRevision)")
            let manufacturer = accessory.manufacturer
            print("Manufacturer: \(manufacturer)")
            let modelNumber = accessory.modelNumber
            print("Model Number: \(modelNumber)")
            let serialNumber = accessory.serialNumber
            print("Serial Number: \(serialNumber)")
            let name = accessory.name
            print("Accessory Name: \(name)")
        }
    }
}
