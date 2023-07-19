//
//  AWSManager.swift
//  Pods
//
//  Created by Melanie Herbert on 6/22/23.
//

import Amplify
import AmplifyPlugins
import Foundation

class AWSManager {
    
    static let shared = AWSManager()
    let s3BucketKey = "data/"
    
    // Store multiple logs in a dictionary
    var logData: [[String: Any]] = []
    var rpmLogData: [[String: Any]] = []
    var temperatureLogData: [[String: Any]] = []
    var voltageLogData: [[String: Any]] = []
    
    var nextUploadTime: Date = Date().addingTimeInterval(10*6) // The initial time to start uploading the data
    
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
        
        checkAndUpload()
    }
    
    func checkAndUpload() {
        let date = Date()
        if date >= nextUploadTime {
            uploadToS3()
        }
    }
    
    func logTemperatureData(_ temperature: String) {
        // Similar to logRPMData
    }
    
    func logVoltageData(_ voltage: String) {
        // Similar to logRPMData
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
