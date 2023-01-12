//
//  Reachability.swift
//  WebViewiOS
//
//  Created by abozaid.ibrahim on 12.01.23.
//

import Network
public class Reachability {
    private let monitor = NWPathMonitor()
    var isConnected = true
    private init() {
        checkConnection()
    }

    static let shared = Reachability()
    func checkConnection() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: DispatchQueue.global(qos: .userInitiated))
    }
}
