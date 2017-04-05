import Foundation
import Util

class Agent : Hashable {
	let ID: Int
	let hashValue: Int

    var cma: CMA = (0.5)
	private var enthusiasm: Float = 0
    
	/*var wealth: Float = 301000
	var daily_income: Float = 145.896067416 // Average values US obtained through google
	var daily_cost: Float = 115.936986301*/
	var connectedness: Float = 0
	var ownsGun: Bool = false
    
    /// A value that indicates whether this agent was already visited in a graph traversal
    var visited = false

	init(_ id: Int) {
		ID = id
		hashValue = ID
        cma.happiness = 1
	}

	convenience init() {
		self.init(counter.next() ?? -1)
	}

	static func ==(_ first: Agent, _ second: Agent) -> Bool {
		return first.ID == second.ID
	}
    
    private func determineExtend() -> Int {
        return Int(positive(fromFS: enthusiasm) * 3)
    }
    
    private func determineWeapon() -> Weapon {
        if ownsGun {
            return .Gun
        } else {
            return .Other
        }
    }

	func checkCrime() -> CrimeType? {
		//if happiness < 0.5 {
		if connectedness * log(happiness) < 1 {
			return generateCrimeType()
		} else {
			return nil
		}
	}
    
    func generateCrimeType() -> CrimeType? {
        var newCMA = cma
        var type: CrimeType? = nil
        let extend = determineExtend()
        for t in CrimeType.all {
            let possibleExtend = t.attributes.isExtendable ? extend : 1
            let weapon = determineWeapon()
            let expectedOutcome = t.getOutcome(val: increaseProbability(0.5, by: positive(enthusiasm)), for: weapon)
            let candidateCMA = t.wishedUpdate(attributes: cma, for: expectedOutcome, by: possibleExtend)
            if candidateCMA > newCMA {
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

	func updateConnectedness(node: Node<Agent>) {
		connectedness = 0
		for edge in node.edgeList() {
			connectedness += pow(edge.weight, 2)
		}
	}
}

/// crime motivating attributes: first: happiness
typealias CMA = (Float)

func +(_ lhs: CMA, _ rhs: CMA) -> CMA {
    return (lhs+rhs)
}

func -(_ lhs: CMA, _ rhs: CMA) -> CMA {
    return (lhs-rhs)
}

func val(_ at: CMA) -> Float{
    return at
}

func abs(_ arg: CMA) -> Float {
    return sqrt(arg*arg)
}

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
