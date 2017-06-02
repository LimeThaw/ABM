import Foundation
import Util

func deviation(of rec: Record, last: Record) -> Double {
	var ret = ((rec.2 / Double(rec.0)) * 100000.0 - 1.020821918)^^2 // Violent crime rate
	ret += (((rec.3 / Double(rec.0)) * 100000.0 - 0.28051726)^^2) // Firearm crime rate
	ret += ((Double(rec.0-last.0) / Double(rec.0) * 100000.0 - 214.794520548)^^2) // Population change
	return ret
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