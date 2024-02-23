//
//  WebView+Ext.swift
//  SmartCaptureDemo
//
//  Copyright © 2016-2023 Onfido. All rights reserved.
//

import WebKit

extension WKWebView {
    func load(_ htmlFileName: String?, version: WebSDKVersion, onError: (ApiManagerError) -> Void) {

        guard let filePath = Bundle.main.path(forResource: htmlFileName, ofType: "html") else {
            return onError(.invalidFilePath)
        }

        do {
            switch version {
            case .scl:
                guard let url = URL(string: ApiEndpoint.sclWebView.path) else { return }
                load(URLRequest(url: url))
            case .cdn:
                let htmlString = try String(contentsOfFile: filePath, encoding: .utf8)
                loadHTMLString(htmlString, baseURL: URL(fileURLWithPath: filePath))
            }
        } catch let error {
            onError(.contentConversion(error.localizedDescription))
        }
    }
}
