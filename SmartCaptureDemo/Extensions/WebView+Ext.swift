//
//  WebView+Ext.swift
//
//  Copyright © 2016-2024 Onfido. All rights reserved.
//

import WebKit

extension WKWebView {
    func loadOnfido(sdkTargetVersion: String, onError: (ApiManagerError) -> Void) {
        guard let filePath = Bundle.main.path(forResource: "index", ofType: "html") else {
            return onError(.invalidFilePath)
        }

        do {
            let htmlString = try String(contentsOfFile: filePath, encoding: .utf8)
                .replacingOccurrences(of: "$SDK_TARGET_VERSION", with: sdkTargetVersion)

            loadHTMLString(htmlString, baseURL: URL(fileURLWithPath: filePath))
        } catch {
            onError(.contentConversion("\(error)"))
        }
    }
}
