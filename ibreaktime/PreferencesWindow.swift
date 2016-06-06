//
//  PreferencesWindow.swift
//  ibreaktime
//
//  Created by oleg on 06.04.16.
//  Copyright © 2016 Oleg Orlov. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
	func preferencesDidUpdate()
	func showSecondsCheckboxClicked(showSeconds: Bool)
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
	var delegate: PreferencesWindowDelegate?
	
	@IBOutlet weak var workIntervalField: NSTextField!
	@IBOutlet weak var breakIntervalField: NSTextField!
	@IBOutlet weak var maxIdleIntervalField: NSTextField!
	@IBOutlet weak var showSecondsCheckbox: NSButton!
	
	@IBAction func showSecondsCheckboxClicked(sender: AnyObject) {
		delegate?.showSecondsCheckboxClicked(Bool(showSecondsCheckbox.integerValue))
	}
	
	override var windowNibName : String! {
		return "PreferencesWindow"
	}
	
	override func windowDidLoad() {
		super.windowDidLoad()
		self.window?.center()
		self.window?.makeKeyAndOrderFront(nil)
		NSApp.activateIgnoringOtherApps(true)
		
		let defaults = NSUserDefaults.standardUserDefaults()
		workIntervalField.integerValue = defaults.integerForKey("workInterval") / 60
		breakIntervalField.integerValue = defaults.integerForKey("breakInterval") / 60
		maxIdleIntervalField.integerValue = defaults.integerForKey("maxIdleInterval")
		showSecondsCheckbox.integerValue = Int(defaults.boolForKey("showSeconds"))
	}
	
	func windowWillClose(notification: NSNotification) {
		let defaults = NSUserDefaults.standardUserDefaults()
		
		defaults.setValue(workIntervalField.integerValue * 60, forKey: "workInterval")
		defaults.setValue(breakIntervalField.integerValue * 60, forKey: "breakInterval")
		defaults.setValue(maxIdleIntervalField.integerValue, forKey: "maxIdleInterval")
		defaults.setValue(Bool(showSecondsCheckbox.integerValue), forKey: "showSeconds")
		delegate?.preferencesDidUpdate()
	}
	
	
}
