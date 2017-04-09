import Foundation
import Util

let n = 100

var graph = Graph<Agent>()
var tmpc = Counter(0)

// generate social network
for i in 0..<n {
	var newAgent = Agent(tmpc.next()!)
	newAgent.cma = Float(rand.nextNormal(mu: Double(newAgent.cma), sig: 4.0))
	newAgent.enthusiasm = Float(rand.nextNormal(mu: Double(newAgent.enthusiasm), sig: 2.0))
    newAgent.moral = Float(rand.nextNormal(mu: Double(newAgent.moral), sig: 2.0))
	/*if Random.get_next() % 100 <= 5 { // Person is unemployed
		new_agent.daily_income = 15
	}*/
    if rand.next(prob: 0.33) { // Person owns a firearm
		newAgent.ownsGun = true
	}

	graph.addNode(withValue: newAgent)
}

for i in 0...3*n {
	var fst = Int(rand.next()%n)
	var snd = Int(rand.next()%n)
	graph.addEdge(from: fst, to: snd, weight: Float(rand.nextNormal(mu: 1.0)))
}

for i in 0..<n {
	var node = graph.find(hash: i)
	node?.value.updateConnectedness(node: node!)
}

// run the model
var crimeCounts: [(Int, Int, Int, Int)] = []
for d in 0..<365 {
	var crimeCount1 = 0
	var crimeCount2 = 0
	var cnt = graph.nodeCount
	var hap = graph.nodeList.map({$0.value.cma}).reduce(0.0, +)/Float(graph.nodeCount + 1)
	for node in graph.nodeList {
		var agent = node.value
		var decision = agent.checkCrime()
        if let type = decision {
            //print(type)
            let nodes = graph.nodeList
            let other = nodes[rand.next(max: nodes.count)]
            agent.executeCrime(type: type, on: other.value)
            if type == CrimeType.Murder {
                crimeCount1 += 1
            } else {
                crimeCount2 += 1
            }
        }
        
        // bring a bit movement into the people
        agent.cma += Float(rand.nextNormal(mu: 0, sig: 0.02))
        agent.enthusiasm += Float(rand.nextNormal(mu: 0, sig: 0.1))
        agent.moral += Float(rand.nextNormal(mu: 0, sig: 0.2))
	}
    let entry = (crimeCount1, crimeCount2, cnt, Int(hap*10))
	crimeCounts += [entry]
    print(entry)
}

//print(crime_counts)

try NSString(string: String(describing: crimeCounts)).write(toFile: "out.txt", atomically: false, encoding: 2)
