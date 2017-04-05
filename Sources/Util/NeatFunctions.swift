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

public func ^^ (radix: Double, power: Double) -> Double {
    return pow(radix, power)
}

/*
 The following functions define conversions between different scales. The following scales are defined with their neutral value and the case(s) for which to use them.
 (-inf, inf) : neutral value: 0. Good for addition / subtraction. Attributes are normally expressend in this scale with a uniform / normal distribution.
 [0, inf) : neutral value: 1. Good for multiplication. Usually used to express attributes as factors.
 [0, 1]: neutral value: 0.5. Good for expressing probability. Usually used to express a attribute in a specific range.
 */

/// Converts from (-inf, inf) to [0, inf)
public func positive(fromFS val: Float) -> Float {
    return exp(val)
}

/// Converts from [0,1] to [0, inf)
public func positive(fromProb val: Float) -> Float {
    return log(1-val) * log(0.5)
}

/// converts from [0, inf) to (-inf, inf)
public func fullScale(fromPos val: Float) -> Float {
    return log(val)
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
    if factor < 1 {
        factor = 1/(1-factor)
    }
    return 1 -  exp(factor*(-log(1-p)))
}