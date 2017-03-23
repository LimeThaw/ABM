import Foundation

class Agent : Hashable {
	let ID: Int
	let hashValue: Int

	var happiness: Float = 0.5
	/*var wealth: Float = 301000
	var daily_income: Float = 145.896067416 // Average values US obtained through google
	var daily_cost: Float = 115.936986301*/
	var connectedness: Float = 0
	var owns_gun: Bool = false

	init() {
		ID = Counter.get_next()
		hashValue = ID
	}

	static func ==(_ first: Agent, _ second: Agent) -> Bool {
		return first.ID == second.ID
	}

	func check_crime() -> Int {
		if happiness < 0.5 {
		//if connectedness < 1.5 {
			return 1
		} else {
			return 0
		}
	}

	func execute_crime(type: Int, on other: Agent) {
		self.happiness += 0.2
		other.happiness -= 0.2
	}

	func update_connectedness(node: Node<Agent>) {
		connectedness = 0
		var i = 0
		repeat {
			let edge = node.edges[i]
			if edge == nil {
				break;
			}
			connectedness += pow(edge!.weight, 2.0)
			i += 1
		} while true
	}
}