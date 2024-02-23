//
//  ApiEndpoint.swift
//  SmartCaptureDemo
//
//  Copyright © 2016-2023 Onfido. All rights reserved.
//

import Foundation

enum ApiEndpoint {
    case applicantApi
    case sdkTokenApi(applicantID: String)
    case workFlowRunApi(applicantID: String)
    case sclWebView

    var path: String {
        switch self {
        case .applicantApi:
            return "v3.3/applicants"
        case .sdkTokenApi:
            return "v3.3/sdk_token"
        case .workFlowRunApi:
            return "v3.6/workflow_runs"
        case .sclWebView:
            return "https://crowd-testing.eu.onfido.app/f/755350ab-4ed2-4e4f-8834-d57c98513658/"
        }
    }
}
