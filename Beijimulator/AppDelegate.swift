//
//  AppDelegate.swift
//  Beijimulator
//
//  Created by Jan on 16/03/2017.
//  Copyright © 2017 Primlo. All rights reserved.
//

import Cocoa



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static let AQI_MAXIMUM_VALUE = 300

    var window: NSWindow!
    var statusBarItem: NSStatusItem!
    var beijimulateMenuItem: NSMenuItem!
    
    var aqiFetcher: AQIFetcher?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = BeijimulationWindow()
        
        let menu = NSMenu()
        beijimulateMenuItem = NSMenuItem()
        beijimulateMenuItem.title = "Stop Beijimulating"
        beijimulateMenuItem.target = self
        beijimulateMenuItem.action = #selector(toggleBeijimulation(sender:))
        menu.addItem(beijimulateMenuItem)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit(sender:)), keyEquivalent: "q"))
        
        statusBarItem = NSStatusBar.system().statusItem(withLength: -1)
        statusBarItem.menu = menu
        
        aqiFetcher = AQIFetcher()
        aqiFetcher?.subscribe(callback: { aqi in
            self.statusBarItem.title = "\(aqi)"
            
            let aqiCapped = min(aqi, AppDelegate.AQI_MAXIMUM_VALUE)
            
            let alpha = CGFloat(aqiCapped) / CGFloat(AppDelegate.AQI_MAXIMUM_VALUE) * 0.66
            
            self.window.backgroundColor = NSColor(white: 0.66, alpha: alpha)
            self.window.alphaValue = 1
        })
        aqiFetcher?.startFetching()
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
