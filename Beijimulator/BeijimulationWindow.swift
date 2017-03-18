//
//  BeijimulationWindow.swift
//  Beijimulator
//
//  Created by Jan on 18/03/2017.
//  Copyright © 2017 Primlo. All rights reserved.
//

import Foundation
import Cocoa

class BeijimulationWindow: NSWindow {
    init() {
        guard let windowRect = NSScreen.main()?.frame else {
            exit(-1)
        }
        
        super.init(
            contentRect: windowRect,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        
        self.isReleasedWhenClosed = true
        self.level = Int(CGShieldingWindowLevel())
        self.alphaValue = 0
        self.isOpaque = false
        self.ignoresMouseEvents = true
        self.orderFrontRegardless()
    }
}
