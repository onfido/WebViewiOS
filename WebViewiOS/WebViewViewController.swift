//
//  WebViewViewController.swift
//  WebViewiOS
//
//  Created by Pedro Henrique on 15/09/2022.
//

import Foundation
import WebKit
import UIKit

class WebViewViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        /// Load script from js file
        guard
            let scriptPath = Bundle.main.path(forResource: "webview_script", ofType: "js"),
            let scriptSource = try? String(contentsOfFile: scriptPath)
        else { return }

        /// Inject script into WebView controller
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        let contentController = WKUserContentController()
        contentController.addUserScript(script)

        /// Add callback handlers see `WKScriptMessageHandler`
        contentController.add(self, name: "errorHandler")
        contentController.add(self, name: "successHandler")

        /// Configure WebView
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.userContentController = contentController

        /// Load the URL and present the WebView content
        let url = URL(string: "https://crowd-testing.eu.onfido.app/f/755350ab-4ed2-4e4f-8834-d57c98513658/")!

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.load(URLRequest(url: url))

        view = webView

    }
}

extension WebViewViewController: WKScriptMessageHandler {
    /// Handling the callback from WebView
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let messageBody = message.body as? String ?? ""

        if message.name == "errorHandler" {
            /// Handle Error
            print(messageBody)
        }

        if message.name == "successHandler" {
            /// Handle Success
            print(messageBody)
        }
    }
}
