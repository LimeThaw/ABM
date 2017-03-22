
// Simple, non-thread-safe, non-cryptographic pseudo-random number generator
// using linear congruence
class Random {
	private static var last: Int = 13579

	static func get_next() -> Int {
		last = (1103515245 * last + 12345) % 2147483647
		return last
	}

	static func set_seed(to new_seed: Int) {
		last = new_seed
	}
}