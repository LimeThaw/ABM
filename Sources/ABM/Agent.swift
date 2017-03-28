import Foundation
import Util

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

	init(_ id: Int) {
		ID = id
		hashValue = ID
	}

	convenience init() {
		self.init(counter.next() ?? -1)
	}

	static func ==(_ first: Agent, _ second: Agent) -> Bool {
		return first.ID == second.ID
	}

	func checkCrime() -> Int {
		//if happiness < 0.5 {
		if connectedness * happiness < 1 {
			if enthusiasm > 10 && happiness < 0.5 {
				return 2
			}
			return 1
		} else {
			return 0
		}
	}

	func executeCrime(type: Int, on other: Agent?, within graph: Graph<Agent>) {
		if other != nil && other != self{
			switch type {
			case 1:
				self.happiness += 0.2
				other!.happiness -= 0.2
				self.enthusiasm += self.enthusiasm / 10
			case 2:
				graph.removeNode(withValue: other!)
				enthusiasm *= 0.2
			default:
				_ = 1 // The hackszs!
			}
		}
	}

	func updateConnectedness(node: Node<Agent>) {
		connectedness = 0
		for edge in node.edgeList() {
			connectedness += pow(edge?.weight ?? 0, 2)
		}
	}
}