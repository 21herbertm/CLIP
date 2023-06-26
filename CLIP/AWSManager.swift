//
//  AWSManager.swift
//  Pods
//
//  Created by Melanie Herbert on 6/22/23.
//

import Foundation
import AWSCore
import AWSCognito
import AWSAuthCore
import AWSAuthUI
import AWSCognitoIdentityProvider
import AWSUserPoolsSignIn
import AWSMobileClient

class AWSManager {
    static let shared = AWSManager()
    
    private init() {}
    
    func initialize() {
        AWSDDLog.sharedInstance.logLevel = .info // Set log level as desired
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        
        let userPoolId = "us-east-1_0HSPmqQoE" // Replace with your User Pool ID
        let clientId = "138gvukqt59557bintiqbhqtdn" // Replace with your Client ID
        
        let serviceConfiguration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: nil)
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: clientId, clientSecret: nil, poolId: userPoolId)
        
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: "UserPool")
        
        AWSSignInManager.sharedInstance().register(signInProvider: AWSCognitoUserPoolsSignInProvider())
        

        AWSMobileClient.default().initialize { (userState, error) in
            if let error = error {
                print("AWSMobileClient initialization error: \(error.localizedDescription)")
            } else if let userState = userState {
                print("AWSMobileClient is initialized and userState: \(userState.rawValue)")
            }
        }
    }
}

