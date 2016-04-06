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
		workIntervalField.integerValue = defaults.integerForKey("workInterval")
		breakIntervalField.integerValue = defaults.integerForKey("breakInterval")
    }
	
	func windowWillClose(notification: NSNotification) {
		let defaults = NSUserDefaults.standardUserDefaults()
		var w = workIntervalField.integerValue
		var b = breakIntervalField.integerValue
		
		if w <= 0 || w > 600 {
			w = 55
			workIntervalField.integerValue = w
		}

		if b <= 0 || b > 600 {
			b = 5
			breakIntervalField.integerValue = b
		}

		defaults.setValue(w, forKey: "workInterval")
		defaults.setValue(b, forKey: "breakInterval")
		delegate?.preferencesDidUpdate()
	}
	

}
