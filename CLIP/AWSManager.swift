//
//  AWSManager.swift
//  Pods
//
//  Created by Melanie Herbert on 6/22/23.
//

import Amplify
import AmplifyPlugins
import Foundation

class AWSManager: ObservableObject {
    
    static let shared = AWSManager()
    let s3BucketKey = "data/"

    // Store multiple logs in a dictionary
    var logData: [[String: Any]] = []
    var rpmLogData: [[String: Any]] = []
    var temperatureLogData: [[String: Any]] = []
    var voltageLogData: [[String: Any]] = []
    @Published var totalMiles: Double = 0.0
    var totalMilesLogData: [[String: Any]] = []

    
    var nextUploadTime: Date = Date().addingTimeInterval(10*6) // The initial time to start uploading the data
   
    var rpmChartData: [Double] {
        return self.rpmLogData.compactMap { logEntry in
            if let rpmString = logEntry["rpm"] as? String, let rpm = Double(rpmString) {
                return rpm
            }
            return nil
        }
    }
    
    var voltageChartData: [Double] {
        return self.voltageLogData.compactMap { logEntry in
            if let voltageString = logEntry["voltage"] as? String, let voltage = Double(voltageString) {
                return voltage
            }
            return nil
        }
    }

    var temperatureChartData: [Double] {
        return self.temperatureLogData.compactMap { logEntry in
            if let temperatureString = logEntry["temperature"] as? String, let temperature = Double(temperatureString) {
                return temperature
            }
            return nil
        }
    }

    var combinedChartData: [(Double, Double, Double)] {
        let rpmData = rpmChartData
        let voltageData = voltageChartData
        let temperatureData = temperatureChartData

        var combinedData: [(Double, Double, Double)] = []

        for i in 0..<rpmData.count {
            let rpm = rpmData[i]
            let voltage = i < voltageData.count ? voltageData[i] : nil
            let temperature = i < temperatureData.count ? temperatureData[i] : nil

            combinedData.append((rpm, voltage ?? 0, temperature ?? 0))
        }

        return combinedData
    }

    // Function to accumulate data
    func logData(_ data: String) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        // Construct the log data
        let currentLogData: [String: Any] = ["date": dateString, "data": data]
        
        self.logData.append(currentLogData) // append the data to the logData array
        
        // Check if it's time to upload the data to S3
        if date >= nextUploadTime {
            uploadToS3()
        }
    }
    
    func logRPMData(_ rpm: String) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        let currentLogData: [String: Any] = ["date": dateString, "rpm": rpm]
        self.rpmLogData.append(currentLogData)
        
        updateTotalMiles()
        checkAndUpload()
    }
    
    func logTemperatureData(_ temperature: String) {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = formatter.string(from: date)
            
            let currentLogData: [String: Any] = ["date": dateString, "temperature": temperature]
            self.temperatureLogData.append(currentLogData)
            
            checkAndUpload()
        }

        // Function to log voltage data
    func logVoltageData(_ voltage: String) {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = formatter.string(from: date)
            
            let currentLogData: [String: Any] = ["date": dateString, "voltage": voltage]
            self.voltageLogData.append(currentLogData)
            
            checkAndUpload()
        }
    
    func checkAndUpload() {
        let date = Date()
        if date >= nextUploadTime {
            uploadToS3()
        }
    }
    
    
    func calculateTotalMiles() -> Double {
        let polePairs = 14.0
        let radius = 1.5 // inches
        let inchesPerMile = 63360.0
        // Calculate circumference in inches
        let circumference = 2 * Double.pi * radius
        // Convert circumference from inches to miles
        let circumferenceMiles = circumference / inchesPerMile
        var totalDistance = 0.0/100
        var rpmTotal = 0.0
        var rpmCount = 0

        for item in rpmLogData {
            // Get the rpm value, convert from String to Double, then divide by polePairs
            if let rpmString = item["rpm"] as? String, let rpm = Double(rpmString) {
                rpmTotal += rpm
                rpmCount += 1
                // Every 10 readings (one second), calculate distance and reset
                if rpmCount == 10 {
                    let averageRpm = rpmTotal / 10
                    let convertedRpm = averageRpm / polePairs
                    let distance = convertedRpm * circumferenceMiles
                    totalDistance += distance
                    // Reset the total and count for the next second
                    rpmTotal = 0.0
                    rpmCount = 0
                }
            }
        }
        // Handle the case where there's a partial second at the end
        if rpmCount > 0 {
            let averageRpm = rpmTotal / Double(rpmCount)
            let convertedRpm = averageRpm / polePairs
            let distance = convertedRpm * circumferenceMiles
            totalDistance += distance
        }
        return totalDistance
    }


    func updateTotalMiles() {
        totalMiles = calculateTotalMiles()
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)

        let totalMilesLogEntry: [String: Any] = ["date": dateString, "totalMiles": totalMiles]
        self.totalMilesLogData.append(totalMilesLogEntry)
        
        print("Total miles: \(totalMiles)")
    }


    
    // Function to upload accumulated data to S3
    // Function to upload accumulated data to S3
    func uploadToS3() {
        uploadData(self.logData, keyPrefix: "tv1/") {
            self.logData = []
        }
        uploadData(self.rpmLogData, keyPrefix: "rpm/") {
            self.rpmLogData = []
        }
        uploadData(self.temperatureLogData, keyPrefix: "temperature/") {
            self.temperatureLogData = []
        }
        uploadData(self.voltageLogData, keyPrefix: "voltage/") {
            self.voltageLogData = []
        }
        
        uploadData(self.totalMilesLogData, keyPrefix: "totalMiles/") {
                self.totalMilesLogData = []
            }
        // reset the next upload time
        self.nextUploadTime = Date().addingTimeInterval(10*6)
    }

    private func uploadData(_ data: [[String: Any]], keyPrefix: String, completion: @escaping ()->()) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: Date())
        
        // Convert the log data to JSON
        let dataJSON: Data
        do {
            dataJSON = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            print("Error serializing the JSON: \(error)")
            return
        }
        
        // Prepare the key
        let key = "\(self.s3BucketKey)\(keyPrefix)\(dateString).json"
        
        // Upload the data
        Amplify.Storage.uploadData(key: key, data: dataJSON, options: nil) { result in
            switch result {
            case .success(let key):
                print("Upload completed: \(key)")
                // clear the accumulated log data after successful upload
                completion()
            case .failure(let storageError):
                print("Upload failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        }
    }
}
