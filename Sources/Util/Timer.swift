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

public func tic() {
    start = DispatchTime.now().uptimeNanoseconds
}

public func toc() -> Int {
    let res = DispatchTime.now().uptimeNanoseconds - start + passed
    start = 0
    passed = 0
    return Int(res)
}

public func tec() -> Int {
    passed += DispatchTime.now().uptimeNanoseconds - start
    start = 0
    return Int(passed)
}

public func tocS() -> Float {
    return Float(toc()) / 1000000000
}

public func tecS() -> Float {
    return Float(tec()) / 1000000000
}
