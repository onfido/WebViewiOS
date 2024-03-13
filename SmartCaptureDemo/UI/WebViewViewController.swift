//
//  WebViewViewController.swift
//  SmartCaptureDemo
//
//  Copyright © 2016-2023 Onfido. All rights reserved.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {

    // MARK: - Properties

    private let sdkTargetVersion: String
    private var webView: WKWebView?

    // MARK: - Initialization

    init(sdkTargetVersion: String) {
        self.sdkTargetVersion = sdkTargetVersion
        super.init(nibName: nil, bundle: nil)

        Task {
            do {
                let applicantResponse: ApplicantResponse = try await ApiManager.shared.getData(from: .applicantApi)

                let sdkTokenResponse: SDKTokenResponse = try await ApiManager.shared.getData(
                    from: .sdkTokenApi(applicantID: applicantResponse.id)
                )
                let workflowRunResponse: WorkFlowRunResponse = try await ApiManager.shared.getData(
                    from: .workFlowRunApi(applicantID: applicantResponse.id)
                )
                
                print("ℹ️ Integrating with Web SDK version: \(sdkTargetVersion)")
                
                let config = setupWebConfiguration(token: sdkTokenResponse.token, workflowRunId: workflowRunResponse.id)
                setupWebView(config: config, sdkTargetVersion: sdkTargetVersion)
            } catch {
                print("⚠️: \(error)")
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
    }

    // MARK: - Private Methods
    @MainActor private func setupWebConfiguration(token: String?, workflowRunId: String?) -> WKWebViewConfiguration {
        /// Load script
        var scriptSource: String?

        guard let token, let workflowRunId else { return WKWebViewConfiguration() }
        
        let contentController = WKUserContentController()

        scriptSource = """
        Onfido.init({
            token: '\(token)',
            workflowRunId: '\(workflowRunId)',
            containerId: 'onfido-mount'
        })
        """
        
        /// Inject script into WebView controller
        guard let scriptSource else { return WKWebViewConfiguration() }
      
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript( script)

        /// Add callback handlers see `WKScriptMessageHandler`
        contentController.add(self, name: "errorHandler")
        contentController.add(self, name: "successHandler")

        /// Configure WebView
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController

        return webConfiguration
    }

    private func setupWebView(config: WKWebViewConfiguration, sdkTargetVersion: String) {
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.navigationDelegate = self

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        
        webView.load("index", sdkTargetVersion: sdkTargetVersion) { err in
            print("🚨🚨🚨: \(err)")
        }
        
        self.webView = webView
    }
}

extension WebViewViewController: WKNavigationDelegate {
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
    }
}

extension WebViewViewController: WKScriptMessageHandler {
    /// Handling the callback from WebView
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let messageBody = message.body as? String ?? ""

        if message.name == "errorHandler" {
            /// Handle Error
            print(messageBody)
            showAlert(title: "Error", with: messageBody)
        } else if message.name == "successHandler" {
            /// Handle Success
            print(messageBody)
            showAlert(title: "Smart Capture", with: messageBody)
        }
    }

    func showAlert(title: String, with message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(.init(title: "Okay", style: .cancel))
        present(controller, animated: true)
    }
}
