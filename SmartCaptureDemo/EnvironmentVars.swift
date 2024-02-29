//
//  EnvironmentVars.swift
//  SmartCaptureDemo
//
//  Created by Jonathan Go on 27.02.24.
//

import Foundation

enum EnvironmentVars {
    private static let infoDict: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist is not found")
        }
        return dict
    }()

    static let apiKey: String = {
        guard let key = EnvironmentVars.infoDict["API_KEY"] as? String else {
            fatalError("api key not found")
        }
        return key
    }()

    static let workflowID: String = {
        guard let id = EnvironmentVars.infoDict["WORKFLOW_ID"] as? String else {
            fatalError("workflow id not found")
        }
        return id
    }()
}
