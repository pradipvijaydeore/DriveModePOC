//
//  DeviceDetailView.swift
//  DriveModePOC
//
//  Created by Pradip on 05/12/24.
//

import SwiftUI

struct DeviceDetailView: View {
    @State var device: PairedDevice
    @ObservedObject var manager: PairedDevicesManager
    @State private var showActionSheet = false
    @State private var showConfirmation = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(device.name)
                .font(.largeTitle)
                .padding(.top)
            
            Text("Enable this option to automatically trigger Drive Mode when your device connects to this Bluetooth or in-car USB device.")
                .multilineTextAlignment(.center)
                .padding()
            
            Toggle("Enable Drive Mode", isOn: $device.driveModeEnabled)
                .padding()
                .onChange(of: device.driveModeEnabled) { _ in
                    manager.updateDevice(device)
                }
            
            Divider()
            
            Button("Forget This Device") {
                showActionSheet = true
            }
            .foregroundColor(.red)
            .padding()
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Forget This Device"),
                    message: Text("Are you sure you want to forget this device?"),
                    buttons: [
                        .destructive(Text("Confirm")) {
                            manager.forgetDevice(device)
                        },
                        .cancel()
                    ]
                )
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(device.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
