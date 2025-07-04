//
//  WebSDK.swift
//
//  Copyright © 2016-2025 Onfido. All rights reserved.
//

import Foundation

import UIKit
import WebKit

public class WebSDKViewController: UIViewController {
    private var webView: WKWebView! // Not recommended, used for demo purposes only

    private let permissionManager = PermissionsManager()
    private lazy var permissionHandler: PermissionHandler = .init(permissionManager: permissionManager)

    private let sdkParameters: SdkParameters
    private let webSDKVersion: String
    private let onComplete: (Any) -> Void
    private let onError: (Any) -> Void

    public init(
        sdkParameters: SdkParameters,
        webSDKVersion: String,
        onComplete: @escaping (Any) -> Void,
        onError: @escaping (Any) -> Void
    ) {
        self.sdkParameters = sdkParameters
        self.webSDKVersion = webSDKVersion
        self.onError = onError
        self.onComplete = onComplete

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = webViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = permissionHandler // This is key to manage permissions the WebView requests
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        setupWebView()
    }

    // MARK: - Public API

    public func start() throws {
        let handler = WebCallbacks(onComplete: { (result: Any?, _: WKFrameInfo) in
            self.onComplete(result!)
        }, onError: { (result: Any?, _: WKFrameInfo) in
            self.onError(result!)
        }, atDocumentStart: atDocumentStart)

        webView.configuration.userContentController.add(handler, name: "callbackHandler")

        let html = try html(
            version: self.webSDKVersion,
            parameters: getParametersAsJson(parameters: self.sdkParameters)
        )
        webView.loadHTMLString(html, baseURL: URL(string: "https://sdk.onfido.com"))
    }

    // MARK: - Private API

    @MainActor
    private func webViewConfiguration() -> WKWebViewConfiguration {
        // Inject js that dispatches a message handler for every frame
        let script = """
        window.webkit.messageHandlers.callbackHandler.postMessage({ method: "atDocumentStart" });
        
        (() => {
            let audioRequested = false;
            let videoRequested = false;
            window.addEventListener('message', (e) => {
                try {
                    const data = JSON.parse(e.data);
                    if (data.type === 'request-permissions' && (audioRequested !== data.which.audio || videoRequested !== data.which.video)) {
                        audioRequested = data.which.audio;
                        videoRequested = data.which.video;
                        navigator.mediaDevices.getUserMedia(data.which)
                    }
                } catch (e) {
                    console.error(e);
                }
            }, false)
        })();
        
        """

        // Set up user content controller for JavaScript communication
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        return configuration
    }

    private func setupWebView() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func getParametersAsJson(parameters: SdkParameters) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(parameters)
        return String(data: jsonData, encoding: .utf8)!
    }

    private func atDocumentStart(_: Any?, frame: WKFrameInfo) {
        let audio = permissionManager.permissionStatus(for: .microphone) == .granted
        let video = permissionManager.permissionStatus(for: .camera) == .granted

        if audio || video {
            // invoke getUserMedia, which will invoke the permissionHandler and grant permissions to the iframe
            if #available(iOS 14.0, *) {
                webView.evaluateJavaScript(
                    "navigator.mediaDevices.getUserMedia({ audio: \(WebUtils.jsBool(audio)), video: \(WebUtils.jsBool(video)) })",
                    in: frame,
                    in: .page
                ) { result in
                    switch result {
                    case let .success(value): print("Success: \(value)")
                    case let .failure(error): print("Error: \(error)")
                    }
                }
            }
        }
    }

    // Load a URL in the WebView
    public func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    // Invoke a JavaScript method
    public func invokeJavaScript(_ script: String, completion: ((Result<Any?, Error>) -> Void)? = nil) {
        webView.evaluateJavaScript(script) { result, error in
            if let error {
                completion?(.failure(error))
            } else {
                completion?(.success(result))
            }
        }
    }

    func html(version: String, parameters: String) -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <title>IDV</title>
            <style>
                html, body {
                    height: 100%;
                    width: 100%;
                }
            </style>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script type="module">
                import { Onfido } from 'https://sdk.onfido.com/\(version)/Onfido.js'
                Onfido.init({
                    ...\(parameters),
                    onComplete: (...data) => {
                        window.webkit.messageHandlers.callbackHandler.postMessage({ method: "onComplete", parameters: data })
                    },
                    onError: (...error) => {
                        window.webkit.messageHandlers.callbackHandler.postMessage({ method: "onError", parameters: error })
                    }
                })
            </script>
        </head>
        <body>
        </body>
        </html>
        """
    }
}
