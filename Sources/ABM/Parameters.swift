#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
import Foundation
import Util

let POP_SIZE = 20 // Size of the population; Number of parameter sets per generation
let MATES_PER_ROUND = 4 // Number of new sets per old set - POP_SIZE/(MATES_PER_ROUND+1) sets will survive each round
let ROUNDS = 10 // Number of rounds to do natural selection for
let MUTATION_RATE = 0.3 // Probability that any given parameter is perturbed randomly
var uncertainty: Double = 0.5 // Maximum perturbation magnitude

let DAYS = 10 // Number of days to simulate
let POP = 100_000 // Number of agents to simulate

let RAND_POP_SIZE = 5000

var graphData = [String]()

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

func mate(mom: Double, dad: Double, max: Double = Double.infinity) -> Double {
	var ret = 0.0
	repeat {
		ret = (rand.next(prob: 0.5) ? mom : dad) + (rand.next(prob: MUTATION_RATE) ? rand.nextNormal(sig: uncertainty): 0.0)
	} while ret < 0 || ret > max
	return ret
}

func mate(mom: Int, dad: Int, max: Int = Int.max) -> Int {
	var ret = 0
	repeat {
	 	ret = (rand.next(prob: 0.5) ? mom : dad) + (rand.next(prob: MUTATION_RATE) ? Int(rand.nextNormal(sig: uncertainty)): 0)
	} while ret < 0 || ret > max
	return ret
}

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

func findParameters(ageDist: [(Int, Bool)]) {
	rand = Random()
	var best = [(Double, Parameters)]()
    graphData = try! getGraphData()

	var population = [Parameters]()
	/*let lower = attributeBound.0
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
		))
	}*/
	population = randomSearch(sets: POP_SIZE, days: DAYS, ageDist: ageDist)

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

            let val = runSimulation(ageDist: ageDist, pars, days: DAYS, write: false)
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

func randomSearch(sets: Int = 100, days: Int = 100, ageDist: [(Int, Bool)]) -> [Parameters] {

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
		let pars = Parameters(
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // moral
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // pleasure
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // arousal
			(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // dominance
			rand.nextProb(), // base gain
			rand.nextProb(), // base cost
			rand.next(max: 10), // Average edges per agent
			rand.nextProb()*10, // Initial weight of edges
			rand.nextProb(), // Edge weight decay rate
			maxDecExt, // maxDecExt
			incGun // incGun
		)

		// Test it in simulation
        let val = runSimulation(ageDist: ageDist, pars, days: days, write: false)

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

func randomParameters(ageDist: [(Int, Bool)]) {

	var best = [(Double, Parameters)]()

	for _ in 1...RAND_POP_SIZE {

        // Generate random parameter set
        let lower = attributeBound.0
        let range = attributeBound.1 - attributeBound.0
        var maxDecExt: Double = 0
        var incGun: Double = 0
        while incGun >= maxDecExt {
            maxDecExt = rand.nextProb()*3
            incGun = rand.nextProb()*3
        }
        let pars = Parameters(
            (rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // moral
            (rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // pleasure
            (rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // arousal
            (rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // dominance
            rand.nextProb(), // base gain
            rand.nextProb(), // base cost
            rand.next(max: 10), // Average edges per agent
            rand.nextProb()*10, // Initial weight of edges
            rand.nextProb(), // Edge weight decay rate
            maxDecExt, // maxDecExt
            incGun // incGun
        )

		// Test it in simulation
		let val = runSimulation(ageDist: ageDist, pars, days: DAYS, write: false)

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

func localMin(pars: Parameters, precision: Int = 10, ageDist: [(Int, Bool)]) {
    let days = 30
    let startSteps: [Double] = [2, 1, /*0.1, 0.01, 0.1, 0.01, 0.1, 0.01,*/ 0.5, 0.5, 2, 1, 1, 0.5, 0.5]
    let constraints: [(Double) -> Bool] = [
        { $0 <= 10 && $0 >= -10 },
        { $0 <= 10 && $0 >= -10 },
        /*{ $0 <= 10 && $0 >= -10 },
        { $0 <= 10 && $0 >= -10 },
        { $0 <= 10 && $0 >= -10 },
        { $0 <= 10 && $0 >= -10 },
        { $0 <= 10 && $0 >= -10 },
        { $0 <= 10 && $0 >= -10 },*/
        { $0 <= 1 && $0 >= 0 },
        { $0 <= 1 && $0 >= 0 },
        { $0 <= 20 && $0 >= 0 },
        { $0 <= 10 && $0 >= 0 },
        { $0 <= 1 && $0 >= 0 },
        { $0 <= 3 && $0 >= 0 },
        { $0 <= 3 && $0 >= 0 },
    ]
    
    var editingPars: [Double] = [pars.moral.0, pars.moral.1, /*pars.p.0, pars.p.1, pars.a.0, pars.a.1, pars.d.0, pars.d.1,*/ pars.baseGain, pars.baseCost, Double(pars.edges), pars.edgeWeight, pars.weightDec, pars.maxDecExt, pars.incGun]
    var minFound = false
    var err = runSimulation(ageDist: ageDist, pars, days: days, write: false)
    while !minFound {
        for i in 0..<editingPars.count {
            print()
            print("Parameter number: \(i)")
            if i == 0 {
                minFound = true
            }
            var stepSize = startSteps[i]
            let minStepSize:Double = stepSize/2^^precision
            var improved = false

            while abs(stepSize) > minStepSize {
                if !constraints[i](editingPars[i] + stepSize) {
                    stepSize /= -2.0
                } else {
                    editingPars[i] += stepSize
                    let prevErr = err
                    //err = runSimulation(((editingPars[0],editingPars[1]),(editingPars[2],editingPars[3]),(editingPars[4],editingPars[5]),(editingPars[6],editingPars[7]),editingPars[8],editingPars[9],Int(editingPars[10]),editingPars[11],editingPars[12],editingPars[13],editingPars[14]), days: days, population: pop, write: false)
                    err = runSimulation(ageDist: ageDist, ((editingPars[0],editingPars[1]),pars.p, pars.a, pars.d, editingPars[2],editingPars[3],Int(editingPars[4]),editingPars[5],editingPars[6],editingPars[7],editingPars[8]), days: days, write: false)
                    if err > prevErr {
                        //print("Failed: \(editingPars[i]) for error: \(err)")
                        // reset to previous state
                        editingPars[i] -= stepSize
                        err = prevErr
                        stepSize /= -2.0
                    } else {
                        print("Found better one: \(editingPars[i]) for error: \(err)")
                        improved = true
                        stepSize *= 1.5
                    }
                }
            }
            minFound = minFound && !improved
        }
        print("Current parameters: \(editingPars)")
    }
}
