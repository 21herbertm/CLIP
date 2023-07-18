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
    let s3BucketKey = "rpm_data/"
    
    // Store multiple logs in a dictionary
    var logData: [[String: Any]] = []
    
    var nextUploadTime: Date = Date().addingTimeInterval(10*6) // The initial time to start uploading the data
    
    // Function to accumulate RPM data
  func logRPMData(_ data: String) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        // Construct the log data
        let currentLogData: [String: Any] = ["date": dateString, "rpm": data]
        
        self.logData.append(currentLogData) // append the data to the logData array
        
        // Check if it's time to upload the data to S3
        if date >= nextUploadTime {
            uploadToS3()
        }
    }
    
    // Function to upload accumulated RPM data to S3
    func uploadToS3() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: Date())
        
        // Convert the log data to JSON
        let logDataJSON: Data
        do {
            logDataJSON = try JSONSerialization.data(withJSONObject: self.logData, options: [])
        } catch {
            print("Error serializing the JSON: \(error)")
            return
        }
        
        // Prepare the key
        let key = "\(self.s3BucketKey)logs/\(dateString).json"
        
        // Upload the data
        Amplify.Storage.uploadData(key: key, data: logDataJSON, options: nil) { result in
            switch result {
            case .success(let key):
                print("Upload completed: \(key)")
                self.logData = [] // clear the accumulated log data after successful upload
                self.nextUploadTime = Date().addingTimeInterval(10*60) // reset the next upload time
            case .failure(let storageError):
                print("Upload failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        }
    }
}
