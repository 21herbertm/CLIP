//
//  AWSManager.swift
//  Pods
//
//  Created by Melanie Herbert on 6/22/23.
//

import Amplify
import AmplifyPlugins

class AWSManager {
    
    static let shared = AWSManager()
    let s3BucketKey = "rpm_data/"
    
    // Function to upload RPM data to S3
    func logRPMData(_ data: String) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        // Construct the log data
        let logData: [String: Any] = ["date": dateString, "rpm": data]
        let logDataJSON: Data
        do {
            logDataJSON = try JSONSerialization.data(withJSONObject: logData, options: [])
        } catch {
            print("Error serializing the JSON: \(error)")
            return
        }
        
        let key = "\(self.s3BucketKey)logs/\(dateString).json"
        Amplify.Storage.uploadData(key: key, data: logDataJSON, options: nil) { result in
            switch result {
            case .success(let key):
                print("Upload completed: \(key)")
            case .failure(let storageError):
                print("Upload failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        }
    }
}


/*
        AWSMobileClient.default().initialize { (userState, error) in
            if let error = error {
                print("AWSMobileClient initialization error: \(error.localizedDescription)")
            } else if let userState = userState {
                print("AWSMobileClient is initialized and userState: \(userState.rawValue)")
            }
        }
 */
