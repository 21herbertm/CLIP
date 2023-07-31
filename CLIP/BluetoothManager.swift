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
    @Published var isAuthenticated = false
    @Published var receivedData: String = ""

    var dataCharacteristic: CBCharacteristic?
    
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
        let enterBootloaderCommand = "tR2953253037".data(using: .ascii) // convert string to ASCII bytes
        guard let command = enterBootloaderCommand else { return }
        
        connectedPeripheral?.writeValue(command, for: commandCharacteristic, type: .withResponse)
    }

    // Perform the firmware update
    func updateFirmware() {
        let downloadURL = URL(string: "https://drive.google.com/file/d/1tpHDddaM3pxgfr3wcHORf1bEW1ZnEU9a/view?usp=drive_link")!

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


    // MARK: - CBCentralManagerDelegate Methods

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Handle Bluetooth state changes
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let serviceData = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            if serviceData.contains(CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")) && RSSI.intValue > -55 {
                if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
                    discoveredDevices.append(peripheral)
                }
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
                // To get a single reading
                //let command = "tV1".data(using: .ascii)
                //peripheral.writeValue(command!, for: characteristic, type: .withResponse)
                
                // To enable continuous notifications
                // Uncomment the following lines if you want to enable continuous notifications
                let continuousCommand = "tV".data(using: .ascii)
                peripheral.writeValue(continuousCommand!, for: characteristic, type: .withResponse)
                
            } else if characteristic.uuid == CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E") {
                // RX (receive FROM clip) used here
                peripheral.setNotifyValue(true, for: characteristic)
                self.dataCharacteristic = characteristic // Save the data characteristic
            }
        }
    }
    
    func sendCommand() {
        guard let commandCharacteristic = self.commandCharacteristic else { return }
        let command = "tV1".data(using: .ascii)
        connectedPeripheral?.writeValue(command!, for: commandCharacteristic, type: .withResponse)
    }
    
    
    func fetchDataFromCharacteristic() {
        guard let peripheral = self.connectedPeripheral,
              let characteristic = self.commandCharacteristic else { return }
        
        let command = "tV1".data(using: .ascii)
        peripheral.writeValue(command!, for: characteristic, type: .withResponse)
    }
    
    func formatData(_ data: String) -> String {
        // If the data already contains "qVesc:", return it as is.
        if data.contains("qVesc:") {
            return data
        }
        // Split the string into an array of strings using comma as separator
        let values = data.split(separator: ",")
        
        // Make sure there are enough values
        guard values.count >= 6 else {
            return data // return original data if it doesn't meet expected format
        }
        
        // Format the data into your desired format
        let formattedData = String(format: "qVesc: RPM %d, I %d mA, Vbatt %d mV, Charge %d, Temps %d C, Drive %d",
                                   Int(values[1]) ?? 0,  // Adjusted for RPM
                                   Int(values[0]) ?? 0,  // Adjusted for I
                                   Int(values[2]) ?? 0,
                                   Int(values[3]) ?? 0,
                                   Int(values[4]) ?? 0,
                                   Int(values[5]) ?? 0)
        
        return formattedData
    }
    
    
    func extractRPM(from dataString: String) -> String? {
        // Assuming the RPM value is always followed by a comma
        // First, we locate the range of "RPM "
        if let range = dataString.range(of: "RPM ") {
            // Then, we find the range of the following comma
            if let endRange = dataString[range.upperBound...].firstIndex(of: ",") {
                // Extract the substring from the data string
                let rpmValue = String(dataString[range.upperBound..<endRange])
                return rpmValue
            }
        }
        return nil
    }
    
    
    func extractTemp(from dataString: String) -> String? {
        // Assuming the Temp value is always followed by a comma
        // First, we locate the range of "Temps "
        if let range = dataString.range(of: "Temps ") {
            // Then, we find the range of the following comma
            if let endRange = dataString[range.upperBound...].firstIndex(of: ",") {
                // Extract the substring from the data string
                let tempValue = String(dataString[range.upperBound..<endRange])
                return tempValue
            }
        }
        return nil
    }

    func extractVoltage(from dataString: String) -> String? {
        // Assuming the Voltage value is always followed by a comma
        // First, we locate the range of "Vbatt "
        if let range = dataString.range(of: "Vbatt ") {
            // Then, we find the range of the following comma
            if let endRange = dataString[range.upperBound...].firstIndex(of: ",") {
                // Extract the substring from the data string
                let voltageValue = String(dataString[range.upperBound..<endRange])
                return voltageValue
            }
        }
        return nil
    }

    
    
    
    // Handle received notifications
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Did update value for \(characteristic.uuid.uuidString), error: \(error)")
        
        if characteristic.uuid == CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E") { // TV1 data
            if let data = characteristic.value {
                print("Received data: \(data)")
                if let string = String(data: data, encoding: .ascii) {
                    print("Received string data: \(string)")
                    let formattedData = formatData(string)
                    self.receivedData = formattedData // update the published variable
                    
                    // Extract the RPM value from the data string and log it
                    if let rpmValue = extractRPM(from: formattedData) {
                        AWSManager.shared.logRPMData(rpmValue)
                    }
                    
                    // Extract the Temperature and Voltage values from the data string and log them
                    if let tempValue = extractTemp(from: formattedData) {
                        AWSManager.shared.logTemperatureData(tempValue)
                    }
                    if let voltageValue = extractVoltage(from: formattedData) {
                        AWSManager.shared.logVoltageData(voltageValue)
                    }
                    
                    // Log data to AWS S3...
                    AWSManager.shared.logData(formattedData) // Call the method on the shared instance of AWSManager
                }
            }
        }
        // Add more characteristic UUID checks here if necessary
    }
}
