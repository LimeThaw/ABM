import Foundation
import Util

let n = 111//998

var graph = Graph<Agent>()
var tmpc = Counter(0)

// generate social network
for i in 0..<n {
	var newAgent = Agent(tmpc.next()!)
	newAgent.enthusiasm = Float(rand.nextNormal(mu: Double(newAgent.enthusiasm), sig: 2.0))
    newAgent.moral = Float(rand.nextNormal(mu: Double(newAgent.moral), sig: 2.0))
	/*if Random.get_next() % 100 <= 5 { // Person is unemployed
		new_agent.daily_income = 15
	}*/
    if rand.next(prob: 0.3225) { // Person owns a firearm
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

var changes = [Change]()

// run the model
let days = 365
var crimeCounts: [(Int, Int, Int, Int, Int)] = []
var totalTime = 0
for d in 0..<days {
    tic()
	var crimeCount1 = 0
	var crimeCount2 = 0
	var cnt = graph.nodes.count
	var hap = graph.nodes.values.map({$0.value.cma.pleasure}).reduce(0.0, +)/Float(graph.nodes.count + 1)
	for node in graph.nodes {
		var agent = node.value.value
		var decision = agent.checkCrime()
        if let type = decision {
            //print(type)
            let nextIndex = rand.next(max: graph.nodes.count)
            let other = graph.nodes[graph.nodes.index(graph.nodes.startIndex, offsetBy: nextIndex)].value
			changes.append(Change(toTarget: other, of: ChangeType.function({ o in return agent.executeCrime(type: type, on: o.value) })))
            //agent.executeCrime(type: type, on: other.value)
            if type == CrimeType.Murder {
                crimeCount1 += 1
            } else {
                crimeCount2 += 1
            }
        }

        // bring a bit movement into the people
        agent.cma.pleasure += Float(rand.nextNormal(mu: 0, sig: 0.02))
        agent.cma.arousal += Float(rand.nextNormal(mu: 0, sig: 0.02))
        agent.cma.dominance += Float(rand.nextNormal(mu: 0, sig: 0.02))
        agent.enthusiasm += Float(rand.nextNormal(mu: 0, sig: 0.1))
        agent.moral += Float(rand.nextNormal(mu: 0, sig: 0.2))
	}

	for change in changes {
		change.apply(within: graph)
	}
	changes = [Change]()

    let entry = (crimeCount1, crimeCount2, cnt, Int(hap + 50), (crimeCount1 + crimeCount2) * 100 / cnt)
	crimeCounts += [entry]
    //print(entry)
    totalTime += toc()
}

print("Average time for one day: \(Float(totalTime)/1000000000/Float(days))s")

//print(crime_counts)

try NSString(string: String(describing: crimeCounts)).write(toFile: "out.txt", atomically: false, encoding: 2)
