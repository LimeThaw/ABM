#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
import Foundation
import Util

let POP_SIZE = 50 // Size of the population; Number of parameter sets per generation
let MATES_PER_ROUND = 4 // Number of new sets per old set - POP_SIZE/(MATES_PER_ROUND+1) sets will survive each round
let ROUNDS = 10 // Number of rounds to do natural selection for
let MUTATION_RATE = 0.3 // Probability that any given parameter is perturbed randomly
var uncertainty: Double = 0.5 // Maximum perturbation magnitude

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
	Double,			// BaseCost
	Int				// Average edges per agent
)

func mate(mom: Distribution, dad: Distribution) -> Distribution {
	var child = (0.0, 0.0)
	repeat {
		child.0 = (rand.next(prob: 0.5) ? mom.0 : dad.0) + (rand.next(prob: MUTATION_RATE) ? rand.nextNormal(sig: uncertainty) : 0.0)
	} while child.0 < attributeBound.0 || child.0 > attributeBound.1 // Make sure erwartungswert is inside bounds
	repeat {
		child.1 = (rand.next(prob: 0.5) ? mom.1 : dad.1) + (rand.next(prob: MUTATION_RATE) ? rand.nextNormal(sig: uncertainty) : 0.0)
	} while child.1 < 0 || child.1 > (attributeBound.1 - attributeBound.0)
	return child
}

func mate(mom: Double, dad: Double) -> Double {
	var ret = 0.0
	repeat {
		ret = (rand.next(prob: 0.5) ? mom : dad) + (rand.next(prob: MUTATION_RATE) ? rand.nextNormal(sig: uncertainty): 0.0)
	} while ret < 0 || ret > 2
	return ret
}

func mate(mom: Int, dad: Int) -> Int {
	return (rand.next(prob: 0.5) ? mom : dad) + (rand.next(prob: MUTATION_RATE) ? Int(rand.nextNormal(sig: uncertainty)): 0)
}

func mate(mom: Parameters, dad: Parameters) -> Parameters {
	return Parameters(
		mate(mom: mom.0, dad: dad.0),
		mate(mom: mom.1, dad: dad.1),
		mate(mom: mom.2, dad: dad.2),
		mate(mom: mom.3, dad: dad.3),
		mate(mom: mom.4, dad: dad.4),
		mate(mom: mom.5, dad: dad.5),
		mate(mom: mom.6, dad: dad.6)
	)
}

func findParameters() {
	rand = Random(clock())
	var best = [(Double, Parameters)]()

	var population = [Parameters]()
	let lower = attributeBound.0
	let range = attributeBound.1 - attributeBound.0
	for _ in 1...POP_SIZE {
		population.append((
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // moral
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // pleasure
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // arousal
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // dominance
			rand.nextProb()*2, // base gain
			rand.nextProb()*2, // base cost
			rand.next(max: 10)
		)) // TODO: Implement ranges
	}

	var results = [(Double, Parameters)]()
	var first = true

	for _ in 1...ROUNDS {
		var i = 0
		for pars in population {
			if !first && i < POP_SIZE/(MATES_PER_ROUND+1) {
				let out = results[i].0 == Double.infinity ? "☠️" : "👍"
				print(out, terminator: " ")
				fflush(stdout)
				i += 1
				continue
			}

			let val = runSimulation(pars, days: 30, population: 100)
			let out = val == Double.infinity ? "☠️" : "👍"
			print(out, terminator: " ")
			results.append((val, pars))
			fflush(stdout)
		}
		print("\n")
		results.sort { $0.0 < $1.0 }
		results = Array(results.prefix(POP_SIZE/(MATES_PER_ROUND+1)))
		if (best.count == 0 && results[0].0 < Double.infinity) || (best.count > 0 && results[0].0 < best[best.count-1].0) {
			best.append(results[0])
			print("New best:\n\(results[0].1)\n\t-> \(results[0].0)\n")
		}
		population = [Parameters]()
		for r in results {
			//print("\(r.1)\n\t->\(r.0)\n")
			population.append(r.1)
		}

		var newPopulation = [Parameters]()
		for p in population {
			for _ in 1...MATES_PER_ROUND {
				let op = population[rand.next(max: population.count)]
				newPopulation.append(mate(mom: p, dad: op))
			}
		}
		population += newPopulation

		uncertainty = clamp(uncertainty*0.9, from: 0.1, to: Double.infinity)
		first = false
	}
	try? NSString(string: String(describing: best)).write(toFile: "population.txt", atomically: false, encoding: 2)
}