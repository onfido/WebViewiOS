//
//  MainVC.swift
//  SmartCaptureDemo
//
//  Copyright © 2016-2023 Onfido. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
    }

    // MARK: - Private Methods

    // MARK: - Actions

    @objc func loadWebView() {
        navigationController?.pushViewController(WebViewViewController(sdkTargetVersion: EnvironmentVars.sdkTargetVersion), animated: true)
    }
}

