import Foundation
import CoreBluetooth
import SwiftUI

// BluetoothManager to manage Bluetooth functionality
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    var discoveredPeripherals: [CBPeripheral] = []

    @Published var devices: [CBPeripheral] = []  // List of discovered devices
    @Published var connectedPeripheral: CBPeripheral?  // Current connected peripheral

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        print("1. BluetoothManager init")
    }

    func startScanning() {
        print("2. BluetoothManager startScanning ")
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    func stopScanning() {
        centralManager.stopScan()
    }

    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }

    func forgetDevice(_ peripheral: CBPeripheral) {
        // Remove the peripheral from both the discovered list and the devices list
        discoveredPeripherals.removeAll { $0.identifier == peripheral.identifier }
        devices.removeAll { $0.identifier == peripheral.identifier }
    }

    // MARK: - CBCentralManagerDelegate Methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("3. BluetoothManager centralManagerDidUpdateState ", central.state)
        switch central.state {
        case .poweredOn:
            startScanning()
        case .poweredOff:
            stopScanning()
        default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("5. CBCentralManager  didDiscover peripheral", discoveredPeripherals)
        print("6. CBCentralManager  didDiscover peripheral advertisementData", advertisementData[CBAdvertisementDataLocalNameKey])
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
            devices.append(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        print("BluetoothManager centralManager  didConnect peripheral", peripheral)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if connectedPeripheral?.identifier == peripheral.identifier {
            connectedPeripheral = nil
        }
    }

    // MARK: - CBPeripheralDelegate Methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Handle discovered services if needed
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Handle discovered characteristics if needed
        print("BluetoothManager centralManager  didDiscoverCharacteristicsFor service", service)
    }
}

// BluetoothStatusView to display the list of devices
struct BluetoothStatusView: View {
    @StateObject var bluetoothManager = BluetoothManager()

    var body: some View {
        NavigationView {
            VStack {
                if bluetoothManager.devices.isEmpty {
                    Text("No devices found")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    
                    Text("No devices found")
                        .foregroundColor(.gray)
                        .padding()
                } /*
                    List(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                        VStack(alignment: .leading) {
                            Text(peripheral.name ?? "Unknown Device")
                                .font(.headline)

                            HStack {
                                if bluetoothManager.connectedPeripheral?.identifier == peripheral.identifier {
                                    Text("Connected")
                                        .foregroundColor(.green)
                                }

                                Button(action: {
                                    if bluetoothManager.connectedPeripheral?.identifier == peripheral.identifier {
                                        bluetoothManager.centralManager.cancelPeripheralConnection(peripheral)
                                    } else {
                                        bluetoothManager.connect(to: peripheral)
                                    }
                                }) {
                                    Text(bluetoothManager.connectedPeripheral?.identifier == peripheral.identifier ? "Disconnect" : "Connect")
                                        .foregroundColor(.blue)
                                }

                                Button(action: {
                                    bluetoothManager.forgetDevice(peripheral)
                                }) {
                                    Text("Forget")
                                        .foregroundColor(.red)
                                }
                            }
                            .font(.subheadline)
                        }
                        .padding()
                    }
                } */

                // Show a loading indicator while scanning
                if bluetoothManager.devices.isEmpty {
                    ProgressView("Scanning...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
            }
            .navigationBarTitle("Bluetooth Devices")
            .onAppear {
                bluetoothManager.startScanning()
            }
            .onDisappear {
                bluetoothManager.stopScanning()
            }
        }
    }
}
