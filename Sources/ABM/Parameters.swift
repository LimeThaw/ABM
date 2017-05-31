#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
import Foundation
import Util

let POP_SIZE = 20 // Size of the population; Number of parameter sets per generation
let MATES_PER_ROUND = 4 // Number of new sets per old set - POP_SIZE/(MATES_PER_ROUND+1) sets will survive each round
let ROUNDS = 2 // Number of rounds to do natural selection for
let MUTATION_RATE = 0.3 // Probability that any given parameter is perturbed randomly
var uncertainty: Double = 0.5 // Maximum perturbation magnitude

let DAYS = 30 // Number of days to simulate
let POP = 100_000 // Number of agents to simulate

let RAND_POP_SIZE = 5000

// The parameters describing rand.nextProb() normal distribution
//                        mu,    sigma
typealias Distribution = (Double, Double)

// A set of independent parameters for our simulation
typealias Parameters = (
    moral: Distribution,	// Moral
    p: Distribution,	// Pleasure
    a: Distribution,	// Arousal
    d: Distribution,	// Dominance
    baseGain: Double,			// BaseGain
    baseCost: Double,			// BaseCost
    edges: Int,			// Average edges per agent
    edgeWeight: Double,			// Initial weight of new edges
    weightDec: Double,			// Weight decay per day
    maxDecExt: Double,			// the maximum (percentual) decrease of the success probability with the extend aka maxDecExt
    incGun: Double			// the (percentual) increase of the success probability when using a gun aka incGun
)

// Combine two normal distributions to create a new one
func mate(mom: Distribution, dad: Distribution) -> Distribution {
	var child = (0.0, 0.0)
	repeat {
		child.0 = (rand.next(prob: 0.5) ? mom.0 : dad.0) + (rand.next(prob: MUTATION_RATE) ? rand.nextNormal(sig: uncertainty) : 0.0)
	} while child.0 < attributeBound.0 || child.0 > attributeBound.1 // Make sure Erwartungswert is inside bounds
	repeat {
		child.1 = (rand.next(prob: 0.5) ? mom.1 : dad.1) + (rand.next(prob: MUTATION_RATE) ? rand.nextNormal(sig: uncertainty) : 0.0)
	} while child.1 < 0 || child.1 > (attributeBound.1 - attributeBound.0)
	return child
}

// Combine two Doubles to create a new one
func mate(mom: Double, dad: Double, max: Double = Double.infinity) -> Double {
	var ret = 0.0
	repeat {
		ret = (rand.next(prob: 0.5) ? mom : dad) + (rand.next(prob: MUTATION_RATE) ? rand.nextNormal(sig: uncertainty): 0.0)
	} while ret < 0 || ret > max
	return ret
}

// Combine two integers to create a new one
func mate(mom: Int, dad: Int, max: Int = Int.max) -> Int {
	var ret = 0
	repeat {
	 	ret = (rand.next(prob: 0.5) ? mom : dad) + (rand.next(prob: MUTATION_RATE) ? Int(rand.nextNormal(sig: uncertainty)): 0)
	} while ret < 0 || ret > max
	return ret
}

// Combine two normal distributions to create a new one
// Each parameter of the child can get the value of its mom or dad, and my be perturbed randomly
// The chance of perturbation is MUTATION_RATE, the maximum magnitude is uncertainty
func mate(mom: Parameters, dad: Parameters) -> Parameters {
	return Parameters(
		mate(mom: mom.0, dad: dad.0),
		mate(mom: mom.1, dad: dad.1),
		mate(mom: mom.2, dad: dad.2),
		mate(mom: mom.3, dad: dad.3),
		mate(mom: mom.4, dad: dad.4, max: 2.0),
		mate(mom: mom.5, dad: dad.5, max: 2.0),
		mate(mom: mom.6, dad: dad.6),
		mate(mom: mom.7, dad: dad.7, max: 10.0),
		mate(mom: mom.8, dad: dad.8, max: 1.0),
		mate(mom: mom.9, dad: dad.9, max: 3.0),
		mate(mom: mom.10, dad: dad.10, max: 3.0)
	)
}

func findParameters() {
	rand = Random()
	var best = [(Double, Parameters)]()

	// Initialize population for GA
	var population = [Parameters]()

	// Filter useless candidates from first generation with a random search
	population = randomSearch(sets: POP_SIZE, days: DAYS, pop: POP)

	// Array to remember the badness value of each parameter set
	var results = [(Double, Parameters)]()

	// Remember if this is the first generation - otherwise we already have values for some sets
	var first = true

	// Let's simulate ALL THE ROUNDS!s
	for _ in 1...ROUNDS {

		var i = 0
		for pars in population {
			if !first && i < POP_SIZE/(MATES_PER_ROUND+1) { // Test if we already have a value for this
				let out = results[i].0 == Double.infinity ? "☠️" : "👍" // Output emojis :D
				print(out, terminator: " ")
				fflush(stdout)
				i += 1
				continue
			}

			// We need to simulate these
			let val = runSimulation(pars, days: DAYS, population: POP, write: false)

			let out = val == Double.infinity ? "☠️" : "👍"
			print(out, terminator: " ")
			fflush(stdout)

			// Append results if not in yet
			results.append((val, pars))
		}

		print("\n")

		// Sort the results by badness ascending to get the best parameter sets
		results.sort { $0.0 < $1.0 }
		results = Array(results.prefix(POP_SIZE/(MATES_PER_ROUND+1)))

		// Check to see if we have a new best candidate and if so remember it
		if (best.count == 0 && results[0].0 < Double.infinity) || (best.count > 0 && results[0].0 < best[best.count-1].0) {
			best.append(results[0])
			print("New best:\n\(results[0].1)\n\t-> \(results[0].0)\n")
		}

		// Delete all but the best sets
		population = [Parameters]()
		for r in results {
			population.append(r.1)
		}

		// Mate the best sets
		var newPopulation = [Parameters]()
		for p in population {
			for _ in 1...MATES_PER_ROUND {
				let op = population[rand.next(max: population.count)]
				newPopulation.append(mate(mom: p, dad: op))
			}
		}
		// And append the offspring to the population
		population += newPopulation

		// Reduce uncertainty, but not below 0.1
		uncertainty = clamp(uncertainty*0.9, from: 0.1, to: Double.infinity)
		first = false
	}

	// Write best parameter sets to file population.txt
	try? NSString(string: String(describing: best)).write(toFile: "population.txt", atomically: false, encoding: 2)
}

func randomSearch(sets: Int = 100, days: Int = 100, pop: Int = 100) -> [Parameters] {

	// Our best guesses
	var best = [Parameters]()

	while best.count < sets {

		// Generate random parameter set
		let lower = attributeBound.0
		let range = attributeBound.1 - attributeBound.0
        var maxDecExt: Double = 0
        var incGun: Double = 0
        while incGun >= maxDecExt {
            maxDecExt = rand.nextProb()*3
            incGun = rand.nextProb()*3
        }
		let pars = Parameters( (1,3), (0,1), (0,1), (0,1),
			/*(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // moral
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // pleasure
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // arousal
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // dominance*/
			rand.nextProb(), // base gain
			rand.nextProb(), // base cost
			/*rand.next(max: 10), // Average edges per agent
			rand.nextProb()*10, // Initial weight of edges*/ 5,9,
			rand.nextProb(), // Edge weight decay rate
			maxDecExt, // maxDecExt
			incGun // incGun
		)

		// Test it in simulation
		let val = runSimulation(pars, days: days, population: pop, write: false)

		//if (best.count == 0 && val < Double.infinity) || (best.count > 0 && val < best[best.count-1].0) {
		if val < Double.infinity {
			best.append(pars)
			print("Found one:\n\(pars)\n")
		} else {
			print("☠️")
		}
	}

	//try? NSString(string: String(describing: best)).write(toFile: "population_rand.txt", atomically: false, encoding: 2)
	return best
}

func randomParameters() {

	var best = [(Double, Parameters)]()

	for _ in 1...RAND_POP_SIZE {

		// Generate random parameter set
		let lower = attributeBound.0
		let range = attributeBound.1 - attributeBound.0
		let pars = Parameters(
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // moral
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // pleasure
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // arousal
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // dominance
			rand.nextProb()*2, // base gain
			rand.nextProb()*2, // base cost
			rand.next(max: 10), // Average edges per agent
			rand.nextProb()*10, // Initial weight of edges
			rand.nextProb(), // Edge weight decay rate
			rand.nextProb()*3, // maxDecExt
			rand.nextProb()*3 // incGun
		)

		// Test it in simulation
		let val = runSimulation(pars, days: DAYS, population: POP, write: false)

		var out = ""
		if (best.count == 0 && val < Double.infinity) || (best.count > 0 && val < best[best.count-1].0){
			best.append((val, pars))
			out = "👑"
			print("\n\(val): \(pars)")
		} else {
			out = "😐"
		}
		print(out, terminator: " ")
		fflush(stdout)

	}

	try? NSString(string: String(describing: best)).write(toFile: "population_rand.txt", atomically: false, encoding: 2)
}
