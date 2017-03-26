class Agent : Hashable {
	let ID: Int
	let hashValue: Int

	var happiness: Float = 0.5
	/*var wealth: Float = 301000
	var daily_income: Float = 145.896067416 // Average values US obtained through google
	var daily_cost: Float = 115.936986301*/
	var owns_gun: Bool = false

	init() {
		ID = counter.next()!
		hashValue = ID
	}

	static func ==(_ first: Agent, _ second: Agent) -> Bool {
		return first.ID == second.ID
	}

	func check_crime() -> Int {
		if happiness < 0.5 {
			return 1
		} else {
			return 0
		}
	}

	func execute_crime(type: Int, on other: Agent) {
		self.happiness += 0.2
		other.happiness -= 0.2
	}
}
