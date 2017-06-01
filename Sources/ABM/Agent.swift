import Foundation
import Util

class Agent : Hashable {
	let ID: Int
	let hashValue: Int

    var emotion: Emotion

    var moral: Double = 0
	var age: Int = 0

	var criminalHistory = false // TODO: Does this need to be distributed at start?

	/*var wealth: Float = 301000
	var daily_income: Float = 145.896067416 // Average values US obtained through google
	var daily_cost: Float = 115.936986301*/
	var connectedness: Double = 0
	var ownsGun: Bool = false

    /// A value that indicates whether this agent was already visited in a graph traversal
    var visited = false

	init(_ id: Int, age: Int) {
		ID = id
		hashValue = ID
        emotion = Emotion()
		self.age = age
	}

	// Randomizes agent attributes to make them more heterogenous
	// Does not touch the age, you have to do that yourself.
	public func randomize(_ pars: Parameters) {
		moral = rand.nextNormal(mu: Double((pars.0).0), sig: Double((pars.0).1), range: attributeBound)
		emotion.pleasure = rand.nextNormal(mu: Double((pars.1).0), sig: Double((pars.1).1), range: attributeBound)
		emotion.arousal = rand.nextNormal(mu: Double((pars.2).0), sig: Double((pars.2).1), range: attributeBound)
		emotion.dominance = rand.nextNormal(mu: Double((pars.3).0), sig: Double((pars.3).1), range: attributeBound)

		if rand.next(prob: 0.3225) { // Person owns a firearm
			ownsGun = true
		} else {
			ownsGun = false
		}
	}
/*
	func updateConnectedness(node: GraphNode<Agent>) {
		connectedness = 0
		for edge in node.edges {
			connectedness += pow(edge.value.weight, 2)
		}
	}*/

    public static func conVal(from weight: Double) -> Double{
        return weight^^2
    }

	func checkAttributes() {
		emotion.pleasure = clamp(emotion.pleasure, from: attributeBound.0, to: attributeBound.1)
		emotion.arousal = clamp(emotion.arousal, from: attributeBound.0, to: attributeBound.1)
		emotion.dominance = clamp(emotion.dominance, from: attributeBound.0, to: attributeBound.1)
		moral = clamp(moral, from: attributeBound.0, to: attributeBound.1)
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

func deathProb(age: Int) -> Double {

	// Convert age from days to years
	let yearAge = Double(age)/365.0

	// Agents should not be older than 100 years
	if yearAge >= 100.0 {
		return 1.0
	}

	// Values from https://www.cdc.gov/nchs/data/dvs/mortfinal2007_worktable23r.pdf
	// Tuples contain probability of death and minimum and maximum age of age group
	let ages = [
		(28.6, 0, 5),
		(15.3, 5, 15),
		(79.9, 15, 25),
		(104.9, 25, 35),
		(184.4, 35, 45),
		(420.9, 45, 55),
		(877.7, 55, 65),
		(2011.3, 65, 75),
		(5011.6, 75, 85),
		(12964.5, 85, 100),
	]

	// The age group index
	var index = 0
	for tmpAge in ages {
		if tmpAge.2 > Int(yearAge) {
			break
		} else {
			index += 1
		}
	}

	// Convert from per 100_000 and year to per agent and day
	return ages[index].0 / 100_000.0 / 365.0
}
