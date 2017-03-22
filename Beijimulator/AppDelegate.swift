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
    
    // We cap the AQI value so that the screen stays visible.
    // The AQI data we get are computed using the Chinese
    // formula so 300 seems like a reasonable value.
    static let AQI_MAXIMUM_VALUE = 300

    var window: NSWindow!
    var statusItem: NSStatusItem!
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
        
        statusItem = NSStatusBar.system().statusItem(withLength: -1)
        statusItem.menu = menu
        
        aqiFetcher = AQIFetcher()
        aqiFetcher?.subscribe(callback: { aqi in
            self.statusItem.title = "\(aqi)"
            
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
