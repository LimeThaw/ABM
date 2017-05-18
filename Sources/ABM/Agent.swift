import Foundation
import Util

class Agent : Hashable {
	let ID: Int
	let hashValue: Int

    var emotion: Emotion

    var moral: Double = 3.0
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

	convenience init(_ id: Int) {
		self.init(id, age: 0)
	}

	convenience init() {
		self.init(counter.next() ?? -1)
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

	func updateConnectedness(node: GraphNode<Agent>) {
		connectedness = 0
		for edge in node.edges {
			connectedness += pow(edge.value.weight, 2)
		}
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
	// Gives the probability that a person of given age dies today
	// Actually prob. that a RV ~N(79, 10) takes value age
	// Data from http://data.worldbank.org/indicator/SP.DYN.LE00.IN?end=2015&locations=US&start=1960&view=chart

	// 1/sqrt(2 PI sig^2)
	let coeff = 0.039894228040143267793994605993438186847585863116493465766
	// 2*sig^2
	let twoS2 = 200.0

	var exponent = age-79
	exponent *= exponent
	return coeff * exp(-Double(exponent)/twoS2)
}