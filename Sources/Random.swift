import Foundation

// Simple, non-thread-safe, non-cryptographic pseudo-random number generator
// using linear congruence
class Random {
	private static var last: Int = 13579

	// Returns a random Int
	static func get_next() -> Int {
		last = (1103515245 * last + 12345) % 2147483647
		return last
	}

	// Returns a random, normal-distributed Float.
	static func get_next_normal(mu: Double = 0, sig2: Double = 1) -> Double {
		let u1 = (Double(get_next()) / 10000.0).truncatingRemainder(dividingBy: 1.0)
		let u2 = (Double(get_next()) / 10000.0).truncatingRemainder(dividingBy: 1.0)
		let u3 = sqrt(-1*log(u1)) * cos(2*M_PI*u2) // Box-Muller transform
		return u3 * sqrt(sig2) + mu // Transformation to requested distribution
	}

	static func set_seed(to new_seed: Int) {
		last = new_seed
	}
}