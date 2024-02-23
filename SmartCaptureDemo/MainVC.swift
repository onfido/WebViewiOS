//
//  MainVC.swift
//  SmartCaptureDemo
//
//  Copyright © 2016-2023 Onfido. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    // MARK: - Properties

    private let sclButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("via Smart Capture Link", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "primaryDarkColor")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(sclPressed), for: .primaryActionTriggered)
        return button
    }()

    private let cdnButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("via Content Delivery Network", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "primaryLightColor")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(cdnPressed), for: .primaryActionTriggered)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addSubViews()
        configureConstraints()
    }

    // MARK: - Private Methods

    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Web SDK Demo"
    }

    private func addSubViews() {
        view.addSubview(sclButton)
        view.addSubview(cdnButton)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            sclButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sclButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sclButton.widthAnchor.constraint(equalToConstant: 260),
            sclButton.heightAnchor.constraint(equalToConstant: 52),
            cdnButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            cdnButton.topAnchor.constraint(equalToSystemSpacingBelow: sclButton.bottomAnchor, multiplier: 2),
            cdnButton.widthAnchor.constraint(equalToConstant: 260),
            cdnButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    // MARK: - Actions

    @objc func sclPressed() {
        navigationController?.pushViewController(WebViewViewController(webSDKVersion: .scl), animated: true)
    }

    @objc func cdnPressed() {
        navigationController?.pushViewController(WebViewViewController(webSDKVersion: .cdn), animated: true)
    }
}

