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
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
	var delegate: PreferencesWindowDelegate?
	
	@IBOutlet weak var workIntervalField: NSTextField!
	@IBOutlet weak var breakIntervalField: NSTextField!
	

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
    }
	
	func windowWillClose(notification: NSNotification) {
		let defaults = NSUserDefaults.standardUserDefaults()
		
		defaults.setValue(workIntervalField.integerValue * 60, forKey: "workInterval")
		defaults.setValue(breakIntervalField.integerValue * 60, forKey: "breakInterval")
		delegate?.preferencesDidUpdate()
	}
	

}
