//
//  AboutWindow.swift
//  ibreaktime
//
//  Created by oleg on 06.04.16.
//  Copyright © 2016 Oleg Orlov. All rights reserved.
//

import Cocoa

class AboutWindow: NSWindowController {
	@IBOutlet weak var versionText: NSTextField!

	override var windowNibName : String! {
		return "AboutWindow"
	}
	
	@IBAction func homePage(sender: AnyObject) {
		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/orlv/ibreaktime")!)
	}
	
	override func windowDidLoad() {
		super.windowDidLoad()

		let version : AnyObject! = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"]
		versionText.stringValue = "iBreakTime v\(version)"

		self.window?.center()
		self.window?.makeKeyAndOrderFront(nil)
		NSApp.activateIgnoringOtherApps(true)
	}
}
