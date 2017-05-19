#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
import Foundation
import Util

let POP_SIZE = 30
let MATES_PER_ROUND = 4
let ROUNDS = 5000
let MUTATION_RATE = 0.3
var uncertainty: Double = 0.5

// The parameters describing rand.nextProb() normal distribution
//                        mu,    sigma
typealias Distribution = (Double, Double)

// A set of independent parameters for our simulation
typealias Parameters = (
	Distribution,	// Moral
	Distribution,	// Pleasure
	Distribution,	// Arousal
	Distribution,	// Dominance
	Double,			// BaseGain
	Double			// BaseCost
)

func mate(mom: Distribution, dad: Distribution) -> Distribution {
	var child = (0.0, 0.0)
	child.0 = (rand.next(prob: 0.5) ? mom.0 : dad.0) + (rand.next(prob: MUTATION_RATE) ? rand.nextNormal(sig: uncertainty) : 0.0)
	child.1 = (rand.next(prob: 0.5) ? mom.1 : dad.1) + (rand.next(prob: MUTATION_RATE) ? rand.nextNormal(sig: uncertainty) : 0.0)
	return child
}

func mate(mom: Double, dad: Double) -> Double {
	return (rand.next(prob: 0.5) ? mom : dad) + (rand.next(prob: MUTATION_RATE) ? rand.nextNormal(sig: uncertainty): 0.0)
}

func mate(mom: Parameters, dad: Parameters) -> Parameters {
	let a: Double = 0.0
	var child = ((a, a), (a, a), (a, a), (a, a), a, a)

	child.0 = mate(mom: mom.0, dad: dad.0)
	child.1 = mate(mom: mom.1, dad: dad.1)
	child.2 = mate(mom: mom.2, dad: dad.2)
	child.3 = mate(mom: mom.3, dad: dad.3)
	child.4 = mate(mom: mom.4, dad: dad.4)
	child.5 = mate(mom: mom.5, dad: dad.5)

	return child
}

func findParameters() {
	rand = Random(clock())

	var population = [Parameters]()
	for _ in 1...POP_SIZE {
		population.append(((rand.nextProb(), rand.nextProb()), (rand.nextProb(), rand.nextProb()), (rand.nextProb(), rand.nextProb()), (rand.nextProb(), rand.nextProb()), rand.nextProb(), rand.nextProb())) // TODO: Implement ranges
	}

	for _ in 1...ROUNDS {
		var results = [(Float, Parameters)]()
		for pop in population {
			let val = runSimulation(pop, days: 14, population: 100)
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

		//uncertainty /= 2.0
	}
}