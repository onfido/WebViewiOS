//
//  HTTPURLResponse+Ext.swift
//
//  Copyright © 2016-2024 Onfido. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    func statusCodeChecker() throws {
        switch statusCode {
        case 200 ... 299:
            return
        default:
            throw ApiManagerError.urlError(statuscode: statusCode)
        }
    }
}
