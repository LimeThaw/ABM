import Foundation
import Util

class Agent : Hashable {
	let ID: Int
	let hashValue: Int

	var cma: CMA

    var moral: Float
	var age: Int

	/*var wealth: Float = 301000
	var daily_income: Float = 145.896067416 // Average values US obtained through google
	var daily_cost: Float = 115.936986301*/
	var connectedness: Float = 0
	var ownsGun: Bool = false

    /// A value that indicates whether this agent was already visited in a graph traversal
    var visited = false

	init(id: Int, moral: Float = 3.0, age: Int = 0, ownsGun: Bool = false) {
		self.ID = id
		self.hashValue = ID
		self.moral = moral
		self.age = age
		self.ownsGun = ownsGun
		cma = (Emotion())
	}

	convenience init(_ id: Int) {
		self.init(id: id)
	}

	convenience init() {
		self.init(id: counter.next() ?? -1)
	}

	// Randomizes agent attributes to make them more heterogenous
	// Does not touch the age, you have to do that yourself.
	public func randomize() {
		moral = Float(rand.nextNormal(mu: Double(moral), sig: 2.0))

		if rand.next(prob: 0.3225) { // Person owns a firearm
			ownsGun = true
		} else {
			ownsGun = false
		}
	}

	static func ==(_ first: Agent, _ second: Agent) -> Bool {
		return first.ID == second.ID
	}

    private func determineExtend() -> Int {
        return Int(1.5) // TODO: Revise extend calculation
    }

    private func determineWeapon() -> Weapon {
        if ownsGun {
            return .Gun
        } else {
            return .Other
        }
    }

	func checkCrime() -> CrimeType? {
		return generateCrimeType()
	}

    func generateCrimeType() -> CrimeType? {
        var newCMA = cma
        var type: CrimeType? = nil
        let extend = determineExtend()
        for t in CrimeType.all {
            let possibleExtend = t.attributes.isExtendable ? extend : 1
            let weapon = determineWeapon()
            let expectedOutcome = t.getOutcome(val: increaseProbability(0.5, by: positive(fromFS: 0.0)), for: weapon) //TODO: Replaced enthusiasm with 0.0, find better replacement
            let candidateCMA = t.wishedUpdate(attributes: cma, for: expectedOutcome, by: possibleExtend)
            if val(candidateCMA) - 5*moral > val(newCMA) {
                newCMA = candidateCMA
                type = t
            }
        }
        return type
    }

	func executeCrime(type: CrimeType, on other: Agent) {
        let cg = CrimeGenerator(with: determineWeapon(), type: type)
        cg.generateCrime()(self, other, determineExtend())
	}

	func updateConnectedness(node: GraphNode<Agent>) {
		connectedness = 0
		for edge in node.edges {
			connectedness += pow(edge.value.weight, 2)
		}
	}
}

/// crime motivating attributes: first: happiness
typealias CMA = (Emotion)
func +=(left: inout CMA, right: CMA) {
	left = left + right
}
/*
func +(_ lhs: CMA, _ rhs: CMA) -> CMA {
    return (lhs+rhs)
}

func -(_ lhs: CMA, _ rhs: CMA) -> CMA {
    return (lhs-rhs)
}*/

func val(_ at: CMA) -> Float{
    return at.pleasure - (0.5-at.arousal^^2) + 0.5*at.dominance
}

func abs(_ arg: CMA) -> Float {
	let tmp = val(arg)
    return Float(sqrt(tmp*tmp))
}
/*
func ==(_ lhs: CMA, _ rhs: CMA) -> Bool {
    return val(lhs) == val(rhs)
}

func <(_ lhs: CMA, _ rhs: CMA) -> Bool {
    return val(lhs) < val(rhs)
}

func >(_ lhs: CMA, _ rhs: CMA) -> Bool {
    return val(lhs) > val(rhs)
}

func <=(_ lhs: CMA, _ rhs: CMA) -> Bool {
    return val(lhs) <= val(rhs)
}

func >=(_ lhs: CMA, _ rhs: CMA) -> Bool {
    return val(lhs) >= val(rhs)
}
*/

// Takes a Float between 0 and 100 as percentile, determines an age group and generates a random
// age in days within that group
func getAge(with variable: Float) -> Int {
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

func deathProb(age: Int) -> Float {
	// Gives the probability that a person of given age dies today
	// Actually prob. that a RV ~N(79, 10) takes value age
	// Data from http://data.worldbank.org/indicator/SP.DYN.LE00.IN?end=2015&locations=US&start=1960&view=chart

	// 1/sqrt(2 PI sig^2)
	let coeff = 0.039894228040143267793994605993438186847585863116493465766
	// 2*sig^2
	let twoS2 = 200.0

	var exponent = age-79
	exponent *= exponent
	return Float(coeff * exp(-Double(exponent)/twoS2))
}