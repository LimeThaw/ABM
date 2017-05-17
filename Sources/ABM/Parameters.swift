
let POP_SIZE = 10

// The parameters describing rand.nextProb() normal distribution
//                        mu,    sigma
typealias Distribution = (Float, Float)

// A set of independent parameters for our simulation
//                      moral,        pleasure,     arousal,      dominance
typealias Parameters = (Distribution, Distribution, Distribution, Distribution)

func findParameters() {
	var population = [Parameters]()
	for _ in 1...POP_SIZE {
		population.append(((rand.nextProb(), rand.nextProb()), (rand.nextProb(), rand.nextProb()), (rand.nextProb(), rand.nextProb()), (rand.nextProb(), rand.nextProb())))
	}

	for pop in population {
		print(pop)
		runSimulation(pop, days: 30)
	}
}