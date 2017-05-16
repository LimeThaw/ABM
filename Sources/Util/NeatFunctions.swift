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
    return Int(pow(Double(radix), Double(power)))
}

public func ^^ (radix: Int, power: Double) -> Double {
    return pow(Double(radix), power)
}

public func ^^ (radix: Double, power: Int) -> Double {
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
public func positive(fromFS val: Float) -> Float {
    return val < 0 ? 1/(-val) : val+1
}

/// Converts from [0,1] to [0, inf)
public func positive(fromProb val: Float) -> Float {
    return log(1-val) * log(0.5)
}

/// converts from [0, inf) to (-inf, inf)
public func fullScale(fromPos val: Float) -> Float {
    return val < 1 ? -1/val : val-1
}

/// converts from [0, 1] to (-inf, inf)
public func fullScale(fromProb val: Float) -> Float {
    return fullScale(fromPos: positive(fromProb: val))
}

/// converts from [0, inf) to [0, 1]
public func probability(fromPos val: Float) -> Float {
    return 1 - exp(val / log(0.5))
}

/// converts from (-inf, inf) to [0, 1]
public func probability(fromFS val: Float) -> Float {
    return probability(fromPos: positive(fromFS: val))
}

/*
 The following define some neat functions between ranges
 */

/// increases the probability by a positive factor
public func increaseProbability(_ p: Float, by factor: Float) -> Float {
    assert(0 <= p && p <= 1)
    return probability(fromPos: positive(fromProb: p) * factor)
}

/**
 Converts a value from range [0,1] to a range [lo, up]
 - parameter val: The value to be converted
 - parameter lo: The lower bound of the range
 - parameter up: The upper bound of the range
*/
public func probToRange(from val: Float, lo: Float, up: Float) -> Float {
    return val * (up-lo) + lo
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