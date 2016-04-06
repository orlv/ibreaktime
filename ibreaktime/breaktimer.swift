//
//  breaktimer.swift
//  ibreaktime
//
//  Created by oleg on 06.04.16.
//  Copyright © 2016 Oleg Orlov. All rights reserved.
//

import Cocoa

class breaktimer : NSObject {
	
	let soundFileName = "bowl.wav"
	var timeToWork = true

	var workInterval = 55*60
	var breakInterval = 5*60
	var alertInterval = 20
	
	var leftTime = 0
	let timerInterval = 10
	
	func getIdleTime() -> Int {
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
	
	
	func playSound() {
		NSSound(named: soundFileName)!.play()
	}
	
	func breaktimer() {
		let idle = getIdleTime()

		if timeToWork {
			if idle < alertInterval && leftTime > 0 {
				leftTime -= timerInterval
				if leftTime <= 0 {
					playSound()
				}
			}

			//	Wait until user takes a break
			if leftTime <= 0 && idle >= alertInterval {
				timeToWork = false
				leftTime = breakInterval - alertInterval
			}

			if idle >= breakInterval {
				leftTime = workInterval
			}
		} else {
			leftTime -= timerInterval
			if leftTime <= 0 {
				playSound()
				timeToWork = true
				leftTime = workInterval
			}
		}
	}

	 func start() {
		NSTimer.scheduledTimerWithTimeInterval(Double(timerInterval), target: self, selector: #selector(breaktimer), userInfo: nil, repeats: true)
		leftTime = workInterval
	}
	
}
