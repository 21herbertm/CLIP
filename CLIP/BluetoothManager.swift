//
//  BluetoothManager.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/16/23.
//
import Foundation
import CoreBluetooth
import iOSDFULibrary

class BluetoothManager: NSObject, CBCentralManagerDelegate, ObservableObject, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate {
    @Published var showLaunchScreen = true
    @Published var dfuUpdateFailed = false
    
    func dfuStateDidChange(to state: iOSDFULibrary.DFUState) {
        print("DFU State did change to: \(state.description)")
    }


    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
           DispatchQueue.main.async {
               self.dfuUpdateFailed = true
           }
           print("DFU Error: \(error), message: \(message)")
       }
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        print("DFU Progress did change to \(progress)%, part \(part) of \(totalParts), speed: \(currentSpeedBytesPerSecond) bytes/sec, average speed: \(avgSpeedBytesPerSecond) bytes/sec")
    }

    func logWith(_ level: iOSDFULibrary.LogLevel, message: String) {
        print("DFU Log, level: \(level.name), message: \(message)")
    }
    
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var connectedDevices: [CBPeripheral] = []

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var commandCharacteristic: CBCharacteristic?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

// ******* THE SCANNING - CURRENTLY IT DOES NOT FILTER FOR CLIP DEVICES ***********
    /*
    func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
     */
    
// ******* SCAN SPECIFICALLY FOR CLIP DEVICES ***************
    
    func startScanning() {
         let nusServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E") // NUS service UUID
         let txCharacteristicUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E") // TX (transmit) characteristic UUID
         let rxCharacteristicUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E") // RX (receive) characteristic UUID
         
         let serviceUUIDs = [nusServiceUUID, txCharacteristicUUID, rxCharacteristicUUID]
         
         centralManager.scanForPeripherals(withServices: serviceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }


    func stopScanning() {
        centralManager.stopScan()
    }

    func connectToDevice(_ device: CBPeripheral) {
        centralManager.connect(device, options: nil)
    }

    func disconnectDevice(_ device: CBPeripheral) {
        centralManager.cancelPeripheralConnection(device)
    }

    // Send the special command to tell the device to reboot into Bootloader mode
    func rebootIntoBootloaderMode() {
        guard let commandCharacteristic = self.commandCharacteristic else { return }
        let enterBootloaderCommand: [UInt8] = [0x01]  // or [0x04] depending on your device's documentation THIS VALUE IS SPECIFIC TO THE DEVICE MAY NEED TO CHANGE!
        let command = Data(enterBootloaderCommand)

        connectedPeripheral?.writeValue(command, for: commandCharacteristic, type: .withResponse)
    }

    // Perform the firmware update
    func updateFirmware() {
        guard let path = Bundle.main.path(forResource: "Firmware", ofType: "zip") else {
            print("Failed to find the firmware file in the app bundle.")
            self.dfuUpdateFailed = true
            return
        }

        let url = URL(fileURLWithPath: path)

        guard let selectedFirmware = try? DFUFirmware(urlToZipFile: url) else {
            print("Failed to create DFUFirmware.")
            self.dfuUpdateFailed = true
            return
        }

        guard let connectedPeripheral = connectedPeripheral else {
            print("No device is connected.")
            self.dfuUpdateFailed = true
            return
        }

        let initiator = DFUServiceInitiator(centralManager: centralManager, target: connectedPeripheral).with(firmware: selectedFirmware)
        initiator.logger = self // - to get log info
        initiator.delegate = self // - to be informed about current state and errors
        initiator.progressDelegate = self // - to show progress bar
        initiator.start()
    }

/*
 IF THE FIRMWARE IS ON A SERVER USE THIS CODE:
 func updateFirmware() {
     let downloadURL = URL(string: "https://example.com/path/to/firmware.zip")!

     let task = URLSession.shared.downloadTask(with: downloadURL) { [weak self] localURL, response, error in
         guard let self = self else { return }

         if let localURL = localURL {
             guard let selectedFirmware = try? DFUFirmware(urlToZipFile: localURL) else {
                 print("Failed to create DFUFirmware.")
                 return
             }

             let initiator = DFUServiceInitiator(centralManager: self.centralManager, target: self.connectedPeripheral!).with(firmware: selectedFirmware)
             initiator.logger = self // - to get log info
             initiator.delegate = self // - to be informed about current state and errors
             initiator.progressDelegate = self // - to show progress bar
             initiator.start()
         } else if let error = error {
             print("Failed to download firmware file: \(error)")
         }
     }

     task.resume()
 }
 
 */

    // MARK: - CBCentralManagerDelegate Methods

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Handle Bluetooth state changes
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let serviceData = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            if serviceData.contains(CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")) {
                discoveredDevices.append(peripheral)
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        connectedDevices.append(peripheral)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to peripheral: \(peripheral), error: \(error?.localizedDescription ?? "")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let index = connectedDevices.firstIndex(of: peripheral) {
            connectedDevices.remove(at: index)
        }
        connectedPeripheral = nil
    }

    // MARK: - DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate

    // Implement required methods for handling the firmware update progress and results
}

func dfuStateDidChange(to state: iOSDFULibrary.DFUState) {
    print("Updated DFU State: \(state.description)")
}

func dfuError(_ error: iOSDFULibrary.DFUError, didOccurWithMessage message: String) {
    print("DFU Error: \(error): \(message)")
}

func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
    print("DFU progress: \(progress)%")
}

func logWith(_ level: iOSDFULibrary.LogLevel, message: String) {
    print("DFU \(level.name): \(message)")
}


extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E") {
                self.commandCharacteristic = characteristic
                // TX (send TO clip) used here
            } else if characteristic.uuid == CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E") {
                // RX (receive FROM clip) used here
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
}

