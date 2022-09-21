//
//  ViewController.swift
//  WebViewiOS
//
//  Created by Pedro Henrique on 15/09/2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func didTapVerifyMe(_ sender: Any) {
        self.present(WebViewViewController(), animated: true)
    }
}

