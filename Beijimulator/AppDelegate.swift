//
//  AppDelegate.swift
//  Beijimulator
//
//  Created by Jan on 16/03/2017.
//  Copyright © 2017 Primlo. All rights reserved.
//

import Cocoa

let AQI_MAXIMUM_VALUE: Double = 300

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusBarItem: NSStatusItem!
    var beijimulateMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let mainScreen = NSScreen.screens()?.first else {
            exit(-1)
        }
        
        let windowLevel = CGShieldingWindowLevel()
        let windowRect = mainScreen.frame
        window = NSWindow(
            contentRect: windowRect,
            styleMask: .borderless,
            backing: .buffered,
            defer: false,
            screen: mainScreen)
        
        window.isReleasedWhenClosed = true
        window.level = Int(windowLevel)
        window.alphaValue = 0
        window.isOpaque = false
        window.ignoresMouseEvents = true
        window.orderFrontRegardless()
        
        let menu = NSMenu()
        beijimulateMenuItem = NSMenuItem()
        beijimulateMenuItem.title = "Stop Beijimulating"
        beijimulateMenuItem.target = self
        beijimulateMenuItem.action = #selector(toggleBeijimulation(sender:))
        menu.addItem(beijimulateMenuItem)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit(sender:)), keyEquivalent: "q"))
        
        statusBarItem = NSStatusBar.system().statusItem(withLength: -1)
        statusBarItem.menu = menu
        
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.updateAQI()
        }
        updateAQI()
    }
    
    func updateAQI() {
        let bjAQWebsiteUrlString = "http://zx.bjmemc.com.cn/?timestamp=\(Int(Date().timeIntervalSince1970 * 1000))"
        guard let url = URL(string: bjAQWebsiteUrlString),
            let html = try? String(contentsOf: url, encoding: .utf8) else { return }
        
        let firstSplit = html.components(separatedBy: "var msgIndex = b.decode('")
        let secondElement = firstSplit[1]
        let secondSplit = secondElement.components(separatedBy: "');")
        let base64 = secondSplit[0]

        guard let decodedData = Data(base64Encoded: base64),
            let jsonObject = try? JSONSerialization.jsonObject(with: decodedData) as? [ String: Any],
            let aqi = jsonObject?["aqi"] as? Double else { return }
        
        statusBarItem.title = "\(Int(aqi))"
        
        let aqiCapped = min(aqi, AQI_MAXIMUM_VALUE)
        
        let alpha = CGFloat(aqiCapped / AQI_MAXIMUM_VALUE * 0.66)
        
        window.backgroundColor = NSColor(white: 0.66, alpha: alpha)
        window.alphaValue = 1
    }
    
    func toggleBeijimulation(sender: Any) {
        if window.alphaValue == 0 {
            window.alphaValue = 1
            beijimulateMenuItem.title = "Stop Beijimulating"
        } else {
            window.alphaValue = 0
            beijimulateMenuItem.title = "BEIJIMULATE!"
        }
    }
    
    func quit(sender: Any) {
        exit(0)
    }
}

