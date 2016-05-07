//
//  StatusMenuController.swift
//  ibreaktime
//
//  Created by oleg on 06.04.16.
//  Copyright © 2016 Oleg Orlov. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, PreferencesWindowDelegate {
	@IBOutlet weak var statusMenu: NSMenu!
	
	var preferencesWindow: PreferencesWindow!
	var aboutWindow: AboutWindow!
	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
	let defaults = NSUserDefaults.standardUserDefaults()
	var bt: breaktimer!
	
	@IBAction func quitClicked(sender: AnyObject) {
		NSApplication.sharedApplication().terminate(self)
	}
	
	@IBAction func preferencesClicked(sender: AnyObject) {
		preferencesWindow.showWindow(nil)
		NSApp.activateIgnoringOtherApps(true)
	}
	
	@IBOutlet weak var cyclesMenuItem: NSMenuItem!
	
	@IBAction func cyclesClicked(sender: AnyObject) {
		bt.cyclesCount = 0
		showStatus()
	}
	
	@IBAction func aboutClicked(sender: AnyObject) {
		aboutWindow.showWindow(nil)
		NSApp.activateIgnoringOtherApps(true)
	}
	
	@IBAction func resetTimerClicked(sender: AnyObject) {
		bt.resetTimer()
		showStatus()
	}
	
	func showStatus() {
		if bt.leftTime <= 0 {
			if bt.timeToWork {
				statusItem.title = "Time to Rest"
			}
		} else if !bt.timeToWork {
			statusItem.title = "Rest: \(lroundf(Float(bt.leftTime)/60))"
		} else {
			statusItem.title = String(lroundf(Float(bt.leftTime)/60))
		}
		
		cyclesMenuItem.title = "Cycles: \(bt.cyclesCount)"
	}
	
	override func awakeFromNib() {
		preferencesWindow = PreferencesWindow()
		preferencesWindow.delegate = self
		
		aboutWindow = AboutWindow()
		
		bt = breaktimer()
		bt.start(defaults.integerForKey("workInterval"), defaults.integerForKey("breakInterval"))
		
		showStatus()
		statusItem.menu = statusMenu
		
		defaults.setValue(bt.workInterval, forKey: "workInterval")
		defaults.setValue(bt.breakInterval, forKey: "breakInterval")
		
		showStatus()
		statusItem.menu = statusMenu
		
		NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(showStatus), userInfo: nil, repeats: true)
	}
	
	func preferencesDidUpdate() {
		bt.workInterval = defaults.integerForKey("workInterval")
		bt.breakInterval = defaults.integerForKey("breakInterval")
		
		defaults.setValue(bt.workInterval, forKey: "workInterval")
		defaults.setValue(bt.breakInterval, forKey: "breakInterval")
		
		showStatus()
	}
}
