//
//  WebView.swift
//  SmartCaptureDemo
//
//  Copyright © 2016-2023 Onfido. All rights reserved.
//

import Foundation

enum WebSDKVersion {
    case scl
    case cdn
}

struct ApplicantResponse: Decodable {
    let id: String
}

struct SDKTokenResponse: Decodable {
    let token: String
}

struct WorkFlowRunResponse: Decodable {
    let id: String
}
