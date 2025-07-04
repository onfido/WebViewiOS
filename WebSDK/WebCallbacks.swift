//
//  WebCallbacks.swift
//
//  Copyright © 2016-2025 Onfido. All rights reserved.
//

import WebKit

class WebCallbacks: NSObject, WKScriptMessageHandler {
    private let methodMap: [String: (Any?, WKFrameInfo) -> Void]

    init(
        onComplete: @escaping (Any?, WKFrameInfo) -> Void,
        onError: @escaping (Any?, WKFrameInfo) -> Void,
        atDocumentStart: @escaping (Any?, WKFrameInfo) -> Void
    ) {
        methodMap = [
            "onComplete": onComplete,
            "onError": onError,
            "atDocumentStart": atDocumentStart
        ]

        super.init()
    }

    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if message.name == "callbackHandler", let messageBody = message.body as? [String: Any] {
            // Assuming messageBody contains a "data" key with a String value or an "error" key
            guard let method = messageBody["method"] as? String else {
                fatalError("cannot understand callback payload")
            }

            let parameters = messageBody["parameters"]

            guard let methodHandler = methodMap[method] else {
                fatalError("Unknown method: \(method)")
            }

            methodHandler(parameters, message.frameInfo)
        }
    }
}
