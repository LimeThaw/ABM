//
//  Timer.swift
//  ABM
//
//  Created by Tierry Hörmann on 22.03.17.
//
//

import Foundation
import Dispatch

private var start: UInt64 = 0
private var passed: UInt64 = 0

// Start measuring a time. The time is measured in whole nanoseconds.
public func tic() {
    start = DispatchTime.now().uptimeNanoseconds
}

// Returns the time passed since the last tic() or toc() and resets the timer
public func toc() -> Int {
    let res = DispatchTime.now().uptimeNanoseconds - start + passed
    start = 0
    passed = 0
    return Int(res)
}

// Returns the time passed since the last tic() or toc() but doesn't reset the timer
public func tec() -> Int {
    passed += DispatchTime.now().uptimeNanoseconds - start
    start = 0
    return Int(passed)
}

// Like toc(), but returns the time in seconds as a Float
public func tocS() -> Float {
    return Float(toc()) / 1000000000
}

// Like tec(), but returns the time in seconds as a Float
public func tecS() -> Float {
    return Float(tec()) / 1000000000
}
