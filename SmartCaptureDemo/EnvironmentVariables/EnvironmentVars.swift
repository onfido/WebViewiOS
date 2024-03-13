//
//  EnvironmentVars.swift
//  SmartCaptureDemo
//
//  Created by Jonathan Go on 27.02.24.
//

import Foundation

/*
 Important Note
 The Environment variables are used for internal/demo purposes only. The method used here is appropriate for
 certain requirements, but it is not encouraged for secrets.
 Please see here for more details, specifically, the end regarding secrets: https://nshipster.com/xcconfig
 */

enum EnvironmentVars {
    private static let infoDict: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist is not found")
        }
        return dict
    }()

    static let apiKey: String = {
        guard let key = EnvironmentVars.infoDict["API_KEY"] as? String, !key.isEmpty else {
            fatalError("api key not found")
        }
        return key
    }()

    static let workflowID: String = {
        guard let id = EnvironmentVars.infoDict["WORKFLOW_ID"] as? String, !id.isEmpty else {
            fatalError("Workflow ID not found")
        }
        return id
    }()

    static let sdkTargetVersion: String = {
        guard let version = EnvironmentVars.infoDict["SDK_TARGET_VERSION"] as? String, !version.isEmpty else {
            return "latest"
        }
        return version
    }()
}
