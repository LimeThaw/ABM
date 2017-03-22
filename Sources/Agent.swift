class Agent : Hashable {
	let ID: Int

	let hashValue: Int

	init() {
		ID = Counter.get_next()
		hashValue = ID
	}

	static func ==(_ first: Agent, _ second: Agent) -> Bool {
		return first.ID == second.ID
	}
}