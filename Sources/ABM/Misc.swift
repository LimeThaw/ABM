import Foundation
import Util

func deviation(of recs: [Record]) -> Double {
	var last = recs[0] // Used for population change calculation
	var badness = 0.0 // How much does this run deviate from our "gold standard"?
	var popChange = 0.0, crimes = 0.0, gunCrimes = 0.0, crimeCnt = 0.0 // Accumulation variables
																	   // for average comparison
	for rec in recs {
		badness += ((rec.2 / Double(rec.0)) * 100000.0 - 1.020821918)^^2 // Violent crime rate
		badness += (((rec.3 / Double(rec.0)) * 100000.0 - 0.28051726)^^2) // Firearm crime rate
		badness += ((Double(rec.0-last.0) / Double(rec.0) * 100000.0 - 214.794520548)^^2) // Population change

		// Accumulate for average value comparison
		popChange += abs(Double(rec.0-last.0) / Double(rec.0) * 100000.0)
		crimes += abs((rec.2 / Double(rec.0)) * 100000.0 - 1.020821918)
		crimeCnt += rec.2
		gunCrimes += abs(rec.3 / Double(rec.0) * 100000.0 - 0.28051726)

		last = rec
	}

	if crimeCnt == 0.0 {
		return Double.infinity // If there are no crimes, then this is boring!
	}

	badness = badness / Double(recs.count) // Average square deviation

	badness += ((popChange/Double(recs.count) - 2.14794520548)^^2)
	badness += ((crimes/Double(recs.count) - 1.020821918)^^2) // Add square deviation for our averages
	badness += ((gunCrimes/Double(recs.count) - 0.28051726)^^2)

	return badness
}

// Generates a new agent with age 0 for the given parameters and adds it to the given graph
func addBaby(to graph: Graph<Agent>, with pars: Parameters) {
    let newAgent = Agent(counter.next()!, age: 0)
    newAgent.randomize(pars)
    let newNode = graph.addNode(withValue: newAgent)
    for _ in 1...3 {
        if let next = graph.getRandomNode() {
            graph.addEdge(from: newNode, to: next, weight: rand.nextNormal(mu: 1.5, sig: 0.5))
        }
    }
}

// Returns the number of children that should be born on a day for the given population size
func newKids(pop: Int) -> Int {
    let newGuys = Double(pop) * BIRTH_RATE
    return Int(newGuys) + ((rand.nextProb() < newGuys - floor(newGuys)) ? 1 : 0)
}

func getAgeDist(_ n: Int) -> [Int] {

	// create age distribution
	var ages = [(Int, Bool)]()
	for _ in 0..<365*100 {
	    for i in 0..<ages.count {
	        if ages[i].1 && rand.next(prob: deathProb(age: ages[i].0)) {
	            ages[i].1 = false
	        }
	        ages[i].0 += 1
	    }
	    for _ in 0..<newKids(pop: n) {
	        ages.append((0,true))
	    }
	}

	return ages.filter{ ($0).1 == true }.map{ ($0).0 }
}