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

	private var _workInterval: Int = 55 * 60
	private var _breakInterval: Int = 5 * 60
	
	func updateLeftTime(newInterval: Int, _ prevInterval: Int) {
		if newInterval > prevInterval {
			leftTime += newInterval - prevInterval
		} else {
			leftTime -= prevInterval - newInterval
		}
	}
	
	var workInterval: Int {
		set {
			let prevInterval = _workInterval
			
			if newValue < 60 || newValue > 600 * 60 {
				_workInterval = 55 * 60
			} else {
				_workInterval = newValue
			}
			
			if timeToWork {
				updateLeftTime(_workInterval, prevInterval)
			}
		}
		get {
			return _workInterval
		}
	}
	
	var breakInterval: Int {
		set {
			let prevInterval = _breakInterval
			if newValue < 60 || newValue > 600 * 60 {
				_breakInterval = 5 * 60
			} else {
				_breakInterval = newValue
			}
			
			if !timeToWork {
				updateLeftTime(_breakInterval, prevInterval)
			}
		}
		
		get {
			return _breakInterval
		}
	}
	
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

	 func start(initialWorkInteval: Int, _ initialBreakInterval: Int) {
		workInterval = initialWorkInteval
		breakInterval = initialBreakInterval
		leftTime = workInterval
		NSTimer.scheduledTimerWithTimeInterval(Double(timerInterval), target: self, selector: #selector(breaktimer), userInfo: nil, repeats: true)
	}
	
}
