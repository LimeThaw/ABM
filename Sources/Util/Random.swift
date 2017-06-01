import Foundation
import Dispatch

// Simple, non-thread-safe, non-cryptographic pseudo-random number generator
// using linear congruence
public struct Random{

    /// The current raw value of this random number generator (the value of the last call to next() )
	public private(set) var current: Int

    public init(_ seed: Int){
        current = seed
    }
    public init(){
        current = Int(DispatchTime.now().uptimeNanoseconds)
    }

	/// Returns a random positive Int
	public mutating func next() -> Int {
		current = abs(1103515245 &* current &+ 12345)
		return current
	}

    /// Returns a random Int
    public mutating func nextFS() -> Int {
        let sign: Bool = next()
        let val: Int = next()
        return sign ? val : -val
    }

    /// Returns a random Bool
    public mutating func next() -> Bool {
        return next() % 2 == 0
    }

    /// Returns a random Bool with the given probability that it is true
    /// - parameter prob: the probability whether next is true
    public mutating func next(prob: Double) -> Bool {
        assert(0 <= prob && prob <= 1)
        return nextProb() < prob
    }

    /// Returns a random Int between 0 and max
    /// - parameter max: the maximum value of the returned Int
    public mutating func next(max v: Int) -> Int{
		assert(v>0)
        return next() % v
    }

    /// Returns a random Float in [0,1]
    public mutating func nextProb() -> Double {
        return Double(next()) / Double(Int.max)
    }

	/// Returns a random, normal-distributed Float.
	public mutating func nextNormal(mu: Double = 0, sig: Double = 1, range: (Double, Double)? = nil) -> Double {
        var ret: Double = 0
        repeat {
            var u1 = 0.0
            var u2 = 0.0
            var s = 0.0
            while s >= 1 || s == 0{
                u1 = Double(probToRange(from: nextProb(), lo: -1, up: 1))
                u2 = Double(probToRange(from: nextProb(), lo: -1, up: 1))
                s = u1*u1+u2*u2
            }
            let u3 = u1 * sqrt(-2*log(s)/s) // Box-Muller transform
            ret = u3 * sqrt(sig) + mu // Transformation to requested distribution
        } while range != nil && (ret < range!.0 || ret > range!.1) // repeat until in attribute bound
        return ret
	}

	// Creates and returns a new Random object. The state variables of the new instance and this
	// one are chosen s.t. they generate different sequences, and instances obtained by subsequent
	// duplications from the same instance will be different as well.
	public mutating func duplicate() -> Random {
		current += 2
		return Random(current-1)
	}
}
