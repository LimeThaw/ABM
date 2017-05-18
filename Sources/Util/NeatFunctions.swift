//
//  NeatFunctions.swift
//  ABM
//
//  Created by Tierry Hörmann on 29.03.17.
//
//
import Foundation

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
public func ^^ (radix: Int, power: Int) -> Int {
    if power == 2 {
        return radix*radix
    }
    return Int(pow(Double(radix), Double(power)))
}

public func ^^ (radix: Int, power: Double) -> Double {
    return pow(Double(radix), power)
}

public func ^^ (radix: Double, power: Int) -> Double {
    if power == 2 {
        return radix*radix
    }
    return pow(radix, Double(power))
}

public func ^^ (radix: Float, power: Int) -> Float {
    return pow(radix, Float(power))
}

public func ^^ (radix: Double, power: Double) -> Double {
    return pow(radix, power)
}

/*
 The following functions define conversions between different scales. The following scales are defined with their neutral value and the case(s) for which to use them.
 (-inf, inf) : neutral value: 0. Good for addition / subtraction. Attributes are normally expressend in this scale with a uniform / normal (or other) distribution.
 [0, inf) : neutral value: 1. Good for multiplication. Usually used to express attributes as factors.
 [0, 1]: neutral value: 0.5. Good for expressing probability. Usually used to express a attribute in a specific range.
 */

/// Converts from (-inf, inf) to [0, inf)
public func positive(fromFS val: Double) -> Double {
    return val < 0 ? 1/(-val) : val+1
}

/// Converts from [0,1] to [0, inf)
public func positive(fromProb val: Double) -> Double {
    return log(1-val) * log(0.5)
}

/// converts from [0, inf) to (-inf, inf)
public func fullScale(fromPos val: Double) -> Double {
    return val < 1 ? -1/val : val-1
}

/// converts from [0, 1] to (-inf, inf)
public func fullScale(fromProb val: Double) -> Double {
    return fullScale(fromPos: positive(fromProb: val))
}

/// converts from [0, inf) to [0, 1]
public func probability(fromPos val: Double) -> Double {
    return 1 - exp(val / log(0.5))
}

/// converts from (-inf, inf) to [0, 1]
public func probability(fromFS val: Double) -> Double {
    return probability(fromPos: positive(fromFS: val))
}

/*
 The following define some neat functions between ranges
 */

/**
 Increases the given probability by a given percentage. If the new probability is over 1, then 1 is returned. If the new probability is below 0, then 0 is returned.
 */
public func increaseProb(_ p: Double, by perc: Double) -> Double {
    let ret = p*(1+perc)
    return ret > 0 ? (ret < 1 ? ret : 1) : 0
}

/**
 Converts a value from a range to another range
 */
public func convert(value v: Double, from r1: (Double, Double), to r2: (Double, Double)) -> Double {
    return r2.0 + (r2.1 - r2.0)*((v-r1.0)/(r1.1-r1.0))
}

/**
 Converts a value from range [0,1] to a range [lo, up]
 - parameter val: The value to be converted
 - parameter lo: The lower bound of the range
 - parameter up: The upper bound of the range
*/
public func probToRange(from val: Double, lo: Double, up: Double) -> Double {
    return val * (up-lo) + lo
}


public func fitToRange(_ val: Double, range: (Double, Double)) -> Double {
    return val < range.0 ? range.0 : val > range.1 ? range.1 : val
}

// Function for memoization


/// Turns a pure function without parameters into a memoizing function where the memoized value can be modified
public func memoizeIO<T>(_ fun: @escaping () -> T) -> ((inout T) -> ()) -> T {
    var cache: T? = nil
    return { (f: (inout T) -> ()) -> T in
        if cache == nil {
            cache = fun()
        }
        f(&cache!)
        return cache!
    }
}

/// Turns a pure function without parameters into a memoizing function
public func memoize<T>(_ fun: @escaping () -> T) -> () -> T {
    var cache: T? = nil
    return {
        if cache == nil {
            cache = fun()
        }
        return cache!
    }
}

extension Array {
    public func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

public func clamp<T: Comparable>(_ value: T, from low: T, to high: T) -> T {
	assert(low <= high)
	return value < low ? low : value > high ? high : value
}

public func read(_ path: String) -> String {
	let fileHandle = fopen(path, "r")
    fseek(fileHandle, 0, SEEK_END)
    let fileLen = ftell(fileHandle)
    rewind(fileHandle)
    let mut = UnsafeMutablePointer<UInt8>.allocate(capacity: fileLen + 1)
    fread(mut, 1, fileLen, fileHandle)
    let buff = UnsafeMutableBufferPointer(start: mut, count: fileLen + 1)
    buff.baseAddress?[fileLen] = 0
	let baseAddress = buff.baseAddress!
    let ret =  String(cString: baseAddress)
	fclose(fileHandle)
	return ret
}