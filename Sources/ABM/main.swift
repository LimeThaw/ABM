import Foundation

Random.setSeed(to: 12345)

let n = 100

var graph = Graph<Agent>()
for i in 0..<n {
	var newAgent = Agent()
	newAgent.happiness = Float(Random.getNextNormal(mu: Double(newAgent.happiness), sig2: 0.5))
	newAgent.enthusiasm = Float(Random.getNextNormal(mu: Double(newAgent.enthusiasm), sig2: 1.0))
	/*if Random.get_next() % 100 <= 5 { // Person is unemployed
		new_agent.daily_income = 15
	}
	if Random.get_next() % 3 == 0 { // Person owns a firearm
		new_agent.owns_gun = true
	}*/

	graph.addNode(withValue: newAgent)
}

for i in 0...3*n {
	var fst = Int(Random.getNext()%n)
	var snd = Int(Random.getNext()%n)
	graph.addEdge(from: fst, to: snd, weight: Float(Random.getNextNormal(mu: 1.0)))
}

for i in 0..<n {
	var node = graph.find(hash: i)
	node?.value.updateConnectedness(node: node!)
}

var crimeCounts: [Int] = []
for d in 0..<3650 {
	var crimeCount1 = 0
	var crimeCount2 = 0
	for i in 0..<n {
		var agent = graph.find(hash: i)?.value
		var decision = agent?.checkCrime() ?? 0
		if decision == 1 {
			//print("-> Crime on day \(d) by agent \(i)")
			agent?.executeCrime(type: 1, on: graph.find(hash: Random.getNext()%n)?.value, within: graph)
			crimeCount1 += 1
		} else if decision == 2 {
			//print("-> Crime on day \(d) by agent \(i)")
			agent?.executeCrime(type: 2, on: graph.find(hash: Random.getNext()%n)?.value, within: graph)
			crimeCount2 += 1
		}
	}
	crimeCounts += [crimeCount1, crimeCount2, graph.nodeCount/10]
}

//print(crime_counts)

try NSString(string: String(describing: crimeCounts)).write(toFile: "out.txt", atomically: false, encoding: 2)

