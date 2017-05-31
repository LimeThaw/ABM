import Foundation
import Util

func deviation(of rec: Record, last: Record) -> Double {
	var ret = ((rec.2 / Double(rec.0)) * 100000.0 - 1.020821918)^^2 // Violent crime rate
	ret += (((rec.3 / Double(rec.0)) * 100000.0 - 0.28051726)^^2) // Firearm crime rate
	ret += ((Double(rec.0-last.0) / Double(rec.0) * 100000.0 - 214.794520548)^^2) // Population change
	return ret
}

func addBaby(to graph: Graph<Agent>, with pars: Parameters) {
    //print("birth")
    let newAgent = Agent(counter.next()!, age: 0)
    newAgent.randomize(pars)
    let newNode = graph.addNode(withValue: newAgent)
    for _ in 1...3 {
        if let next = graph.getRandomNode() {
            graph.addEdge(from: newNode, to: next, weight: rand.nextNormal(mu: 1.5, sig: 0.5))
        }
    }
}