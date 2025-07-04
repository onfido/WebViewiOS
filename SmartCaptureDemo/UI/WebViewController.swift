//
//  WebViewViewController.swift
//
//  Copyright © 2016-2024 Onfido. All rights reserved.
//

import UIKit
import WebKit

import WebSDK

final class WebViewController: UIViewController {
    private var applicantID: String!

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setUpLoadingView()

        Task {
            let token = try await createSDKToken()

            let sdkParameters: WebSDK.SdkParameters
            if let workflowID = EnvironmentVars.workflowID {
                do {
                    let workflowRun: WorkFlowRunResponse = try await ApiManager.shared.getData(
                        from: .workFlowRunApi(applicantID: applicantID)
                    )
                    sdkParameters = SdkParameters(token: token, workflowRunId: workflowRun.id)
                } catch {
                    fatalError("Cannot create Workflow Run ID")
                }
            } else {
                sdkParameters = SdkParameters(
                    token: token,
                    steps: [WelcomeStep(), DocumentStep(), FaceStep()]
                )
            }
            let webSDKViewController = WebSDKViewController(
                sdkParameters: sdkParameters,
                webSDKVersion: "v14.49.0",
                onComplete: { data in
                    print("Onfido flow completed with data: \(data)")
                    // Handle completion data, e.g., process as [Any] or cast to expected type
                    if let params = data as? [Any] {
                        print("Parameters: \(params)")
                    }
                },
                onError: { error in
                    print("Onfido flow failed with error: \(error)")
                    // Handle error data
                }
            )

            await MainActor.run {
                webSDKViewController.modalPresentationStyle = .fullScreen
                self.present(webSDKViewController, animated: true) {
                    do {
                        try webSDKViewController.start()
                    } catch {
                        print("Failed to start Onfido flow: \(error)")
                    }
                }
            }
        }
    }

    // MARK: - Private API

    private func createSDKToken() async throws -> String {
        do {
            let apiManager = ApiManager.shared

            let applicantResponse: ApplicantResponse = try await apiManager.getData(from: .applicantApi)
            applicantID = applicantResponse.id
            let sdkTokenResponse: SDKTokenResponse = try await apiManager.getData(
                from: .sdkTokenApi(applicantID: applicantResponse.id)
            )
            return sdkTokenResponse.token
        } catch {
            fatalError("Failed to create SDK Token. Error = \(error)")
        }
    }

    private func setUpLoadingView() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .black
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.widthAnchor.constraint(equalToConstant: 100),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        activityIndicator.startAnimating()
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
    }
}
