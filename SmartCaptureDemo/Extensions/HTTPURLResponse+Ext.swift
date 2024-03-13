//
//  HTTPURLResponse+Ext.swift
//  SmartCaptureDemo
//
//  Copyright © 2016-2023 Onfido. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    func statusCodeChecker() throws {
        switch self.statusCode {
        case 200...299:
            return
        default:
            throw ApiManagerError.urlError(statuscode: self.statusCode)
        }
    }
}
