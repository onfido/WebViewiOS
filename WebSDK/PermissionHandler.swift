//
//  PermissionHandler.swift
//
//  Copyright © 2016-2025 Onfido. All rights reserved.
//

import WebKit

class PermissionHandler: NSObject, WKUIDelegate {
    private let permissionManager: PermissionsManager

    init(permissionManager: PermissionsManager) {
        self.permissionManager = permissionManager
    }

    public func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping @MainActor (WKPermissionDecision) -> Void
    ) {
        func triggerPermissionsToIFrame() {
            let audio = WebUtils.jsBool(permissionManager.permissionStatus(for: .microphone) == .granted)
            let video = WebUtils.jsBool(permissionManager.permissionStatus(for: .camera) == .granted)

            webView.evaluateJavaScript(
                """
                [...document.querySelectorAll("iframe")].forEach(frame => {
                    frame.contentWindow.postMessage(JSON.stringify({
                        type: 'request-permissions',
                        which: {
                            audio: \(audio),
                            video: \(video)
                        }
                    }), "*")
                })
                """
            )
        }

        func processPermissionStatus(_ permission: Permission) {
            switch permissionManager.permissionStatus(for: permission) {
            case .denied, .restricted: decisionHandler(.deny)
            case .granted:
                decisionHandler(.grant)
                triggerPermissionsToIFrame()
            case .undetermined:
                decisionHandler(.prompt)
                triggerPermissionsToIFrame()
            }
        }

        switch type {
        case .camera: processPermissionStatus(.camera)
        case .microphone: processPermissionStatus(.microphone)
        case .cameraAndMicrophone: processPermissionStatus(.cameraAndMicrophone)
        @unknown default: decisionHandler(.prompt)
        }
    }
}
