import Foundation
import Util

class Agent : Hashable {
	let ID: Int
	let hashValue: Int

    var emotion: Emotion

    var moral: Double = 3.0
	var age: Int = 0

	/*var wealth: Float = 301000
	var daily_income: Float = 145.896067416 // Average values US obtained through google
	var daily_cost: Float = 115.936986301*/
	var ownsGun: Bool = false

    /// A value that indicates whether this agent was already visited in a graph traversal
    var visited = false

	init(_ id: Int) {
		ID = id
		hashValue = ID
        emotion = Emotion()
	}

	convenience init() {
		self.init(counter.next() ?? -1)
	}

	static func ==(_ first: Agent, _ second: Agent) -> Bool {
		return first.ID == second.ID
	}
}


// Takes a Double between 0 and 100 as percentile, determines an age group and generates a random
// age in days within that group
func getAge(with variable: Double) -> Int {
	assert(0 <= variable && variable <= 100, "Please give a uniformly random float value in [0;100]")

	// Values from http://www.statsamerica.org/town/ for Wilmington, NC
	// Age groups: (Cumulative percentages (this group or younger), min age, max age)
	let ages = [
		(4.6, 0, 5),
		(18.0, 5, 18),
		(35.4, 18, 25),
		(61.8, 25, 45),
		(85.4, 45, 65),
		(100.0, 65, 100)
	]

	// The age group index
	var index = 0
	for age in ages {
		if age.0 > Double(variable) {
			break
		} else {
			index += 1
		}
	}

	let age = ages[index]
	// Return random age in days within age group
	return rand.next(max: (age.2 - age.1) * 365) + age.1 * 365
}
