//
//  NetworkMonitor.swift
//  APOD
//
//  Created by Akshit Akhoury on 22/05/22.
//

import UIKit
import Network

class NetworkMonitor: NSObject
{
    static let shared = NetworkMonitor()
    
    let monitor:NWPathMonitor
    var connected:Bool
    
    override init()
    {
        monitor = NWPathMonitor()
        connected = false
        super.init()
    }
    func startMonitoring()
    {
        monitor.pathUpdateHandler = {[weak self] path in
            guard let self = self else {return}
            if path.status == .satisfied {
                self.connected = true
            }
            else
            {
                self.connected = false
            }
        }
        
        let monitorQueue = DispatchQueue(label: "Network Monitor")
        monitor.start(queue: monitorQueue)
    }
    
}
