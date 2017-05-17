#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

let POP_SIZE = 50
let MATES_PER_ROUND = 9
let ROUNDS = 5
var uncertainty: Float = 0.2

// The parameters describing rand.nextProb() normal distribution
//                        mu,    sigma
typealias Distribution = (Float, Float)

// A set of independent parameters for our simulation
//                      moral,        pleasure,     arousal,      dominance
typealias Parameters = (Distribution, Distribution, Distribution, Distribution)

func mate(mom: Distribution, dad: Distribution) -> Distribution {
	let a = Float(0.0)
	var child = (a, a)
	let b = rand.nextProb()
	let c = rand.nextProb()
	child.0 = (rand.next(prob: 0.5) ? mom.0 : dad.0) + (rand.next(prob: 0.125) ? b*uncertainty : 0)
	child.1 = (rand.next(prob: 0.5) ? mom.1 : dad.1) + (rand.next(prob: 0.125) ? c*uncertainty : 0)
	return child
}

func mate(mom: Parameters, dad: Parameters) -> Parameters {
	let a: Float = 0.0
	var child = ((a, a), (a, a), (a, a), (a, a))

	child.0 = mate(mom: mom.0, dad: dad.0)
	child.1 = mate(mom: mom.1, dad: dad.1)
	child.2 = mate(mom: mom.2, dad: dad.2)
	child.3 = mate(mom: mom.3, dad: dad.3)

	return child
}

func findParameters() {
	var population = [Parameters]()
	for _ in 1...POP_SIZE {
		population.append(((rand.nextProb(), rand.nextProb()), (rand.nextProb(), rand.nextProb()), (rand.nextProb(), rand.nextProb()), (rand.nextProb(), rand.nextProb())))
	}

	for _ in 1...ROUNDS {
		var results = [(Float, Parameters)]()
		for pop in population {
			let val = runSimulation(pop, days: 14)
			results.append((val, pop))
			print(".", terminator: "")
			fflush(stdout)
		}
		print("\n")
		results.sort { $0.0 < $1.0 }
		population = [Parameters]()
		for r in results {
			print("\(r.1)\n\t->\(r.0)\n")
			population.append(r.1)
		}

		population = Array(population.prefix(POP_SIZE/(MATES_PER_ROUND+1)))
		var newPopulation = [Parameters]()
		for p in population {
			for _ in 1...MATES_PER_ROUND {
				let op = population[rand.next(max: population.count)]
				newPopulation.append(mate(mom: p, dad: op))
			}
		}
		population += newPopulation

		uncertainty /= 2.0
	}
}