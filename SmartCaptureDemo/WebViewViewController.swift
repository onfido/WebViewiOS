//
//  WebViewViewController.swift
//  WebViewiOS
//
//  Created by Pedro Henrique on 15/09/2022.
//

import Foundation
import Network
import UIKit
import WebKit

final class WebViewViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView?
    let connectionView = ConnectionView()
    private let monitor = NWPathMonitor()
    var isConnected = true

    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
        connectionView.retryButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
    }

    @objc func retryAction() {
        loadContent()
    }

    private func checkConnection() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.isConnected = path.status == .satisfied
            if self.isConnected {
                self.showWebViewContent()
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .userInitiated))
    }

    private func loadContent() {
        Reachability.shared.checkConnection()
        if Reachability.shared.isConnected {
            showWebViewContent()
            UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
                self?.connectionView.alpha = 0
                self?.webView?.alpha = 1
            }

        } else { // not connected
            if !view.subviews.contains(connectionView) { // add sub view
                view.setChildConstrainsEqualToParent(subView: connectionView, inset: .init(top: 80, left: 20, bottom: 80, right: 20))
            }
            UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
                self?.connectionView.alpha = 1
                self?.webView?.alpha = 0
            }
        }
    }

    private func showWebViewContent() {
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
        guard let webView = webView else { return }
        webView.load(URLRequest(url: url))

        guard !view.subviews.contains(webView) else { return }
        view.setChildConstrainsEqualToParent(subView: webView)
    }
}

extension WebViewViewController: WKScriptMessageHandler {
    /// Handling the callback from WebView
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let messageBody = message.body as? String ?? ""

        if message.name == "errorHandler" {
            /// Handle Error
            print(messageBody)
            showAlert(with: messageBody)
        } else if message.name == "successHandler" {
            /// Handle Success
            print(messageBody)
            showAlert(with: messageBody)
        }
    }

    private func showAlert(with message: String) {
        let controller = UIAlertController(title: "Smart Capture", message: message, preferredStyle: .alert)
        controller.addAction(.init(title: "Okay", style: .cancel))
        present(controller, animated: true)
    }
}
