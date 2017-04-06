import Foundation
import Dispatch

// Simple, non-thread-safe, non-cryptographic pseudo-random number generator
// using linear congruence
public struct Random{
	private(set) var current: Int

    public init(_ seed: Int){
        current = seed
    }
    public init(){
        current = Int(DispatchTime.now().uptimeNanoseconds)
    }

	// Returns a random Int
	public mutating func next() -> Int {
		current = abs((1103515245 &* current &+ 12345) % 2147483647)
		return current
	}

    public mutating func next() -> Bool {
        return next() % 2 == 0
    }

    public mutating func next(max v: Int) -> Int{
        return next() % v
    }
    
    public mutating func nextProb() -> Float {
        return Float(next()) / Float(Int.max)
    }

	// Returns a random, normal-distributed Float.
	public mutating func nextNormal(mu: Double = 0, sig2: Double = 1) -> Double {
		let u1 = (Double(next() as Int) / 10000.0).truncatingRemainder(dividingBy: 1.0)
		let u2 = (Double(next() as Int) / 10000.0).truncatingRemainder(dividingBy: 1.0)
		let u3 = sqrt(-1*log(u1)) * cos(2*M_PI*u2) // Box-Muller transform
		return u3 * sqrt(sig2) + mu // Transformation to requested distribution
	}
}

var rand = Random(13579)
