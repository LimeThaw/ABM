import Foundation

class Agent : Hashable {
	let ID: Int
	let hashValue: Int

	var happiness: Float = 0.5
	var enthusiasm: Float = 0.5
	/*var wealth: Float = 301000
	var daily_income: Float = 145.896067416 // Average values US obtained through google
	var daily_cost: Float = 115.936986301*/
	var connectedness: Float = 0
	var ownsGun: Bool = false

	init() {
		ID = Counter.getNext()
		hashValue = ID
	}

	static func ==(_ first: Agent, _ second: Agent) -> Bool {
		return first.ID == second.ID
	}

	func checkCrime() -> Int {
		//if happiness < 0.5 {
		if connectedness * happiness < 2.5 {
			if enthusiasm > 1 {
				return 2
			}
			return 1
		} else {
			return 0
		}
	}

	func executeCrime(type: Int, on other: Agent?, within graph: Graph<Agent>) {
		if other != nil {
			switch type {
			case 1:
				self.happiness += 0.2
				other!.happiness -= 0.2
			case 2:
				graph.removeNode(withValue: other!)
				self.happiness += 0.2
				other!.happiness -= 0.2
			default:
				_ = 1 // The hackszs!
			}
		}
	}

	func updateConnectedness(node: Node<Agent>) {
		connectedness = 0
		for edge in node.edges.toList() {
			connectedness += pow(edge.object?.weight ?? 0, 2)
		}
	}
}