//
//  WebViewViewController.swift
//
//  Copyright © 2016-2024 Onfido. All rights reserved.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    // MARK: - Properties

    private let sdkTargetVersion: String
    private var wkWebView: WKWebView?

    // MARK: - Initialization

    init(sdkTargetVersion: String) {
        self.sdkTargetVersion = sdkTargetVersion

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true

        Task {
            let webViewConfiguration = try await createWebViewConfiguration()
            let webView = webView(config: webViewConfiguration, sdkTargetVersion: sdkTargetVersion)
            self.wkWebView = webView
            view.addSubview(webView)
            configureWebViewConstraints()
        }
    }

    // MARK: - Private API

    private func createWebViewConfiguration() async throws -> WKWebViewConfiguration {
        do {
            let apiManager = ApiManager.shared

            let applicantResponse: ApplicantResponse = try await apiManager.getData(from: .applicantApi)
            let sdkTokenResponse: SDKTokenResponse = try await apiManager.getData(
                from: .sdkTokenApi(applicantID: applicantResponse.id)
            )
            let workflowRunResponse: WorkFlowRunResponse = try await apiManager.getData(
                from: .workFlowRunApi(applicantID: applicantResponse.id)
            )

            print("ℹ️ Integrating with Web SDK version: \(sdkTargetVersion)")

            return webViewConfiguration(token: sdkTokenResponse.token, workflowRunId: workflowRunResponse.id)
        } catch {
            fatalError("🚨: Failed to create WKWebViewConfiguration. Error = \(error)")
        }
    }

    @MainActor
    private func webViewConfiguration(token: String?, workflowRunId: String?) -> WKWebViewConfiguration {
        guard let token, let workflowRunId else {
            fatalError("🚨: No token or workflowRunId configured. Cannot launch WebView.")
        }

        let webViewInitialisationScript = """
        Onfido.init({
            token: '\(token)',
            workflowRunId: '\(workflowRunId)',
            containerId: 'onfido-mount'
        })
        """

        let script = WKUserScript(
            source: webViewInitialisationScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )

        let contentController = WKUserContentController()
        contentController.addUserScript(script)

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        webConfiguration.allowsInlineMediaPlayback = true  
        webConfiguration.mediaPlaybackRequiresUserAction = false 
        return webConfiguration
    }

    private func webView(config: WKWebViewConfiguration, sdkTargetVersion: String) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.loadOnfido(sdkTargetVersion: sdkTargetVersion) { err in
            print("🚨: \(err)")
        }
        return webView
    }

    private func configureWebViewConstraints() {
        guard let wkWebView else {
            fatalError("🚨 WKWebView property is nil")
        }

        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wkWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            wkWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wkWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wkWebView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
    }
}
