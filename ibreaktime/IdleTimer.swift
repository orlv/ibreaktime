//
//  IdleTimer.swift
//  ibreaktime
//
//  Created by oleg on 06.06.16.
//  Copyright © 2016 Oleg Orlov. All rights reserved.
//

import Foundation

class IdleTimer {
	private var _idleTime: Int = 0
	private var _maxIdleInterval: Int = 20
	
	var maxIdleInterval: Int {
		set {
			// between 1 second and 30 minutes
			if newValue < 1 || newValue > 30 * 60 {
				_maxIdleInterval = 20
			} else {
				_maxIdleInterval = newValue
			}
		}
		
		get {
			return _maxIdleInterval
		}
	}
	
	var idleTime: Int {
		get {
			return _idleTime
		}
	}
	
	var idle: Bool {
		get {
			return idleTime > maxIdleInterval
		}
	}
	
	func tick() {
		_idleTime = getIdleTime()
	}
	
	private func getIdleTime() -> Int {
		var matchingServices: io_iterator_t = 0
		var idle = 0
		
		if IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &matchingServices) == KERN_SUCCESS {
			let entry: io_registry_entry_t = IOIteratorNext(matchingServices)
			if entry != 0 {
				var dict: Unmanaged<CFMutableDictionary>?
				if (IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0) == KERN_SUCCESS){
					if let dict = dict {
						let d = dict.takeRetainedValue() as NSDictionary
						
						idle = d.valueForKeyPath("HIDIdleTime") as! Int / 1000000000
					}
				}
			}
		}
		
		return idle
	}
}
