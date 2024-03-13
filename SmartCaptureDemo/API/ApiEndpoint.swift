//
//  ApiEndpoint.swift
//
//  Copyright © 2016-2024 Onfido. All rights reserved.
//

import Foundation

enum ApiEndpoint {
    case applicantApi
    case sdkTokenApi(applicantID: String)
    case workFlowRunApi(applicantID: String)

    var path: String {
        switch self {
        case .applicantApi:
            return "v3.3/applicants"
        case .sdkTokenApi:
            return "v3.3/sdk_token"
        case .workFlowRunApi:
            return "v3.6/workflow_runs"
        }
    }
}
