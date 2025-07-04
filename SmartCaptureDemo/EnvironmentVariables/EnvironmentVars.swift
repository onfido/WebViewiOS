//
//  EnvironmentVars.swift
//
//  Copyright © 2016-2024 Onfido. All rights reserved.
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
            fatalError("Cannot locate Info.plist")
        }
        return dict
    }()

    static let apiKey: String = {
        guard let key = EnvironmentVars.infoDict["API_KEY"] as? String, !key.isEmpty else {
            fatalError("Cannot locate API_KEY within Info.plist")
        }
        return key
    }()

    static let workflowID: String? = {
        guard let id = EnvironmentVars.infoDict["WORKFLOW_ID"] as? String else {
            fatalError("Cannot locate WORKFLOW_ID within Info.plist")
        }
        return id.isEmpty ? nil : id
    }()
}
