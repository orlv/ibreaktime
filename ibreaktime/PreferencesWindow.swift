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
	@IBOutlet weak var cyclesResetIdleInterval: NSTextField!
	
	@IBAction func showSecondsCheckboxClicked(sender: AnyObject) {
		delegate?.showSecondsCheckboxClicked(Bool(showSecondsCheckbox.integerValue))
	}
	
	override var windowNibName : String! {
		return "PreferencesWindow"
	}
	
	func loadFields() {
		let defaults = NSUserDefaults.standardUserDefaults()
		
		workIntervalField.integerValue = defaults.integerForKey("workInterval") / 60
		breakIntervalField.integerValue = defaults.integerForKey("breakInterval") / 60
		maxIdleIntervalField.integerValue = defaults.integerForKey("maxIdleInterval")
		cyclesResetIdleInterval.integerValue = defaults.integerForKey("cyclesResetIdleInterval") / (60 * 60)
		showSecondsCheckbox.integerValue = Int(defaults.boolForKey("showSeconds"))
	}
	
	func saveFields() {
		let defaults = NSUserDefaults.standardUserDefaults()
		
		defaults.setValue(workIntervalField.integerValue * 60, forKey: "workInterval")
		defaults.setValue(breakIntervalField.integerValue * 60, forKey: "breakInterval")
		defaults.setValue(maxIdleIntervalField.integerValue, forKey: "maxIdleInterval")
		defaults.setValue(cyclesResetIdleInterval.integerValue * 60 * 60, forKey: "cyclesResetIdleInterval")
		defaults.setValue(Bool(showSecondsCheckbox.integerValue), forKey: "showSeconds")
	}
	
	override func windowDidLoad() {
		super.windowDidLoad()
		self.window?.center()
		self.window?.makeKeyAndOrderFront(nil)
		NSApp.activateIgnoringOtherApps(true)
		
		loadFields()
	}
	
	func windowWillClose(notification: NSNotification) {
		saveFields()
		delegate?.preferencesDidUpdate()
		loadFields()
	}
	
	
}
