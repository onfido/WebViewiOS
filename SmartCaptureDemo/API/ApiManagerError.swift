//
//  APIManagerError.swift
//  SmartCaptureDemo
//
//  Copyright © 2016-2023 Onfido. All rights reserved.
//

import Foundation

enum ApiManagerError: Error {
    case contentConversion(String)
    case invalidFilePath
    case invalidRequestURL
    case serverError
    case invalidData
    case urlError(statuscode: Int)
    case unknown(Error)

    var message: String {
        switch self {
        case let .contentConversion(message):
            return "There was an error converting the filePath to an HTML string. Error: \(message)"
        case .invalidFilePath:
            return "The filePath is invalid"
        case .invalidRequestURL:
            return "The url is invalid, please try again later."
        case .serverError:
            return "There was an error with the server. Please try again."
        case .invalidData:
            return "invalid data"
        case .urlError(statuscode: let statuscode):
            return "There was an an httpResponse status code error: \(statuscode)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
