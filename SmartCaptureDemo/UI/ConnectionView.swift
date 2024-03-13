//
//  ConnectionView.swift
//
//  Copyright © 2016-2024 Onfido. All rights reserved.
//

import UIKit

final class ConnectionView: UIView {
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical

        view.spacing = 20
        return view
    }()

    let label: UILabel = {
        let view = UILabel()
        view.text = "No internet connection detected, please make sure you are connected to the internet to access onfido content."
        view.numberOfLines = 0
        view.textColor = .lightText
        view.lineBreakMode = .byWordWrapping
        return view
    }()

    let retryButton: UIButton = {
        let view = UIButton()
        view.setTitle("Retry", for: .normal)
        view.backgroundColor = .primaryLightColor
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    // initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func setupView() {
        setChildConstrainsEqualToParent(subView: stackView)
        stackView.addArrangedSubview(label)

        stackView.addArrangedSubview(retryButton)
    }
}

extension UIView {
    func setChildConstrainsEqualToParent(subView: UIView, inset: UIEdgeInsets = .zero) {
        addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            leadingAnchor.constraint(equalTo: subView.leadingAnchor, constant: -inset.left),
            trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: inset.right),
            topAnchor.constraint(equalTo: subView.topAnchor, constant: inset.top),
            bottomAnchor.constraint(equalTo: subView.bottomAnchor, constant: inset.bottom)
        ])
    }
}

extension UIColor {
    static var primaryLightColor = UIColor.from(hex: "#353FF4")

    static var primaryDarkColor = UIColor.from(hex: "#3B43D8")
    static func from(hex: String) -> UIColor {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000ff
        let redInt = Int(color >> 16) & mask
        let greenInt = Int(color >> 8) & mask
        let blueInt = Int(color) & mask

        let red = CGFloat(redInt) / 255.0
        let green = CGFloat(greenInt) / 255.0
        let blue = CGFloat(blueInt) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
