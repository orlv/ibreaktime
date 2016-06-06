//
//  breaktimer.swift
//  ibreaktime
//
//  Created by oleg on 06.04.16.
//  Copyright © 2016 Oleg Orlov. All rights reserved.
//

import Cocoa

class IdleTimer {
	var idleTime: Int = 0
	var _maxIdleInterval: Int = 20
	
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
	
	var idle: Bool {
		get {
			return idleTime > maxIdleInterval
		}
	}
	
	func tick() {
		idleTime = getIdleTime()
	}
	
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
}

class Breaktimer : NSObject {
	let soundFileName = "bowl.wav"
	let timerInterval = 1
	let idleTimer = IdleTimer()
	var lastCheckTime = NSDate()
	private var _workInterval: Int = 55 * 60
	private var _breakInterval: Int = 5 * 60
	var timeToWork = true
	var leftTime = 0
	var cyclesCount = 0
	
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
			
			// between 1 and 600 minutes. defaulf: 55 minutes
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
			// between 1 and 600 minutes. defaulf: 5 minutes
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
	
	func playSound() {
		NSSound(named: soundFileName)!.play()
	}
	
	func resetTimer() {
		timeToWork = true
		leftTime = workInterval
	}
	
	func breaktimer() {
		idleTimer.tick()
		
		// check if mac was in sleep mode
		if Int(-lastCheckTime.timeIntervalSinceNow) > breakInterval {
			resetTimer()
		}
		lastCheckTime = NSDate()
		
		if timeToWork {
			if !idleTimer.idle && leftTime > 0 {
				leftTime -= timerInterval
				if leftTime <= 0 {
					playSound()
				}
			}
			
			//	work time is done, wait until user takes a break
			if leftTime <= 0 && idleTimer.idle {
				timeToWork = false
				leftTime = breakInterval - idleTimer.maxIdleInterval
				cyclesCount += 1
			}
			
			// if user takes a break, reset timer
			if idleTimer.idleTime >= breakInterval {
				leftTime = workInterval
			}
		} else { // if time to break
			leftTime -= timerInterval
			if leftTime <= 0 {
				playSound()
				resetTimer()
			}
		}
	}
	
	init(_ workInterval: Int, _ breakInterval: Int, _ maxIdleInterval: Int) {
		super.init()
		self.workInterval = workInterval
		self.breakInterval = breakInterval
		self.idleTimer.maxIdleInterval = maxIdleInterval
		leftTime = workInterval
		
		NSTimer.scheduledTimerWithTimeInterval(Double(timerInterval), target: self, selector: #selector(breaktimer), userInfo: nil, repeats: true)
	}
	
}
