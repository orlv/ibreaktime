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
	}

	@IBOutlet weak var preferencesMenu: NSMenuItem!
	
	@IBAction func aboutClicked(sender: AnyObject) {
		aboutWindow.showWindow(nil)
	}
	
	func timeElapsedTimer() {
		preferencesMenu.title = "Elapsed: \(bt.leftTime/60) min"
	}
	
	override func awakeFromNib() {
		let icon = NSImage(named: "statusbarIcon")
		icon?.template = true
		statusItem.image = icon
		statusItem.menu = statusMenu
		
		preferencesWindow = PreferencesWindow()
		preferencesWindow.delegate = self
		
		aboutWindow = AboutWindow()
		
		bt = breaktimer()
		
		let w = defaults.integerForKey("workInterval")
		if w <= 0  || w > 600 {
			defaults.setValue(bt.workInterval / 60, forKey: "workInterval")
		} else {
			bt.workInterval = w * 60
		}
		
		let b = defaults.integerForKey("breakInterval")
		if b <= 0 || b > 600 {
			defaults.setValue(bt.breakInterval / 60, forKey: "breakInterval")
		} else {
			bt.breakInterval = b * 60
		}
		
		bt.start()
		timeElapsedTimer()
		NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(timeElapsedTimer), userInfo: nil, repeats: true)
	}
	
	func updatePreferences() {
		let w = defaults.integerForKey("workInterval") * 60
		let b = defaults.integerForKey("breakInterval") * 60

		var newInterval:Int
		var prevInterval:Int
		
		if bt!.timeToWork {
			newInterval = w
			prevInterval = bt.workInterval
		} else {
			newInterval = b
			prevInterval = bt.breakInterval
		}
	
		if newInterval > prevInterval {
			bt.leftTime += newInterval - prevInterval
		} else {
			bt.leftTime -= prevInterval - newInterval
		}
		
		bt.workInterval = w
		bt.breakInterval = b
		
		timeElapsedTimer()
	}
	
	func preferencesDidUpdate() {
		updatePreferences()
	}
}
