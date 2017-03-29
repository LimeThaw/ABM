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
