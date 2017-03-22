//
//  AQIFetcher.swift
//  Beijimulator
//
//  Created by Jan on 18/03/2017.
//  Copyright © 2017 Primlo. All rights reserved.
//

import Foundation

typealias AQIFetcherSubscriptionCallback = (_ aqi: Int) -> Void

class AQIFetcher {
    static let TIME_BETWEEN_FETCHES: Double = 60
    
    var subscribers = [AQIFetcherSubscriptionCallback]()
    
    func startFetching() {
        Timer.scheduledTimer(
            timeInterval: AQIFetcher.TIME_BETWEEN_FETCHES,
            target: self,
            selector: #selector(updateAQI),
            userInfo: nil,
            repeats: true
        )
        updateAQI()
    }
    
    func subscribe(callback: @escaping AQIFetcherSubscriptionCallback) {
        subscribers.append(callback)
    }
    
    @objc func updateAQI() {
        print("Updating AQI...")
        let bjAQWebsiteUrlString = "http://zx.bjmemc.com.cn/?timestamp=\(Int(Date().timeIntervalSince1970 * 1000))"
        guard let url = URL(string: bjAQWebsiteUrlString),
            let html = try? String(contentsOf: url, encoding: .utf8) else { return }
        
        let firstSplit = html.components(separatedBy: "var msgIndex = b.decode('")
        let secondElement = firstSplit[1]
        let secondSplit = secondElement.components(separatedBy: "');")
        let base64 = secondSplit[0]
        
        guard let decodedData = Data(base64Encoded: base64),
            let jsonObject = try? JSONSerialization.jsonObject(with: decodedData) as? [ String: Any],
            let aqiDouble = jsonObject?["aqi"] as? Double else { return }
        
        let aqi = Int(aqiDouble)
        
        subscribers.forEach { $0(aqi) }
    }
}
