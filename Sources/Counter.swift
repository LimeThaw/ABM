
// Simple, non-tread-save, static counter class
class Counter {
	static var count: Int = 0 // The next free number

	static func get_next() -> Int { // Get the next free number and increment the count
		count += 1
		return count - 1
	}
}