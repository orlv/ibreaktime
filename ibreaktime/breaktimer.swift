//
//  breaktimer.swift
//  ibreaktime
//
//  Created by oleg on 06.04.16.
//  Copyright © 2016 Oleg Orlov. All rights reserved.
//

import Cocoa

class Breaktimer : NSObject {
	let soundFileName = "bowl.wav"
	let timerInterval = 1
	let idleTimer = IdleTimer()
	var lastCheckTime = NSDate()
	private var _workInterval: Int = 55 * 60
	private var _breakInterval: Int = 5 * 60
	private var _cyclesResetIdleInterval: Int = 5 * 60 * 60
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
	
	var cyclesResetIdleInterval: Int {
		set {
			// between 1 and 12 hours. defaulf: 5 hours
			if newValue < 60 * 60 || newValue > 12 * 60 * 60 {
				_cyclesResetIdleInterval = 5 * 60 * 60
			} else {
				_cyclesResetIdleInterval = newValue
			}
		}
		get {
			return _cyclesResetIdleInterval
		}
	}
	
	func playSound() {
		NSSound(named: soundFileName)!.play()
	}
	
	func resetTimer() {
		timeToWork = true
		leftTime = workInterval
	}
	
	// check if we need reset cycles counter
	func checkCyclesCounter(intervalFromLastTimerTick: Int) {
		if (intervalFromLastTimerTick > cyclesResetIdleInterval) || (idleTimer.idleTime > cyclesResetIdleInterval) {
			cyclesCount = 0
		}
	}
	
	func breaktimer() {
		idleTimer.tick()
		
		let intervalFromLastTimerTick = Int(-lastCheckTime.timeIntervalSinceNow)
		
		// check if mac was in sleep mode
		if intervalFromLastTimerTick > breakInterval {
			resetTimer()
		}
		
		checkCyclesCounter(intervalFromLastTimerTick)
		
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
