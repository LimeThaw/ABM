import Foundation
import Util
import Dispatch

let THREAD_COUNT = 1
// Data source: http://data.worldbank.org/indicator/SP.DYN.CBRT.IN?end=2015&locations=US&start=1960&view=chart
// Recalculated per person and day
let BIRTH_RATE = 0.000033973

let n = 1119//98

var graph = Graph<Agent>()
var tmpc = Counter(0)

// Murders, other crimes, population, happiness, crime rate
typealias Record = (Int, Int, Int, Int, Int)

infix operator +=
func +=(left: inout Record, right: Record) {
	left.0 += right.0
	left.1 += right.1
	left.2 += right.2
	left.3 += right.3
	left.4 += right.4
}

func updateNodes(_ nodeList: [GraphNode<Agent>], within graph: Graph<Agent>)
		-> ([() -> Void], Record) {

	var changes = [() -> Void]()
	var record = Record(0, 0, 0, 0, 0)

	for node in nodeList {

		let agent = node.value
		// Kill agent if too old
		if rand.nextProb() < deathProb(age: agent.age) {
			print("death")
			changes.append({
				for edge in node.edges.values {
					let next = edge.next
					graph.removeEdge(from: node.hashValue, to: next.hashValue)
					next.value.updateConnectedness(node: next)
				}
				graph.removeNode(node: node)
			})
		} else {
			let decision = agent.checkCrime()
			if let type = decision {
				//print(type)
				let nextIndex = rand.next(max: graph.nodes.count)
				let other = graph.nodes[graph.nodes.index(graph.nodes.startIndex, offsetBy: nextIndex)].value
				changes.append(({ return agent.executeCrime(type: type, on: other.value) }))
				//agent.executeCrime(type: type, on: other.value)
				if type == CrimeType.Murder {
					record.0 += 1
				} else {
					record.1 += 1
				}
			}

			var newMoral: Float = 0.0
			var totalWeight: Float = 0.0
			for nextAgent in node.edges {
				// Influence on moral beliefs from agent's neighbors in social network
				newMoral += (nextAgent.value.next.value.moral + nextAgent.value.weight^^2)
				totalWeight += (nextAgent.value.weight^^2)
			}
			// Age factor: The older the agent the less likely he is to change his beliefs
			let oldFac = ((agent.age == 0) ? 0 : (1.0 - (1.0 / Float(agent.age + 1)) + 0.1))
			newMoral = (1.0 - oldFac) * newMoral / Float(node.edges.count) + oldFac * agent.moral

			changes.append({
				// bring a bit movement into the people
				agent.cma.pleasure += Float(rand.nextNormal(mu: 0, sig: 0.01))
				agent.cma.arousal += Float(rand.nextNormal(mu: 0, sig: 0.01))
				agent.cma.dominance += Float(rand.nextNormal(mu: 0, sig: 0.01))
				agent.enthusiasm += Float(rand.nextNormal(mu: 0, sig: 0.1))
				agent.moral += Float(rand.nextNormal(mu: 0, sig: 0.2))
				agent.age += 1
				agent.moral = newMoral
				agent.updateConnectedness(node: node)
			})
		}
	}

	return (changes, record)
}

func addBaby(to graph: Graph<Agent>) {
	print("birth")
	let newAgent = Agent(id: tmpc.next()!, age: 0)
	newAgent.randomize()
	let newNode = graph.addNode(withValue: newAgent)
	for _ in 1...3 {
		var next = Int(rand.next()%graph.nodes.count)
		next = [Int](graph.nodes.keys)[next]
		graph.addEdge(from: newNode.hashValue, to: next,
			weight: Float(rand.nextNormal(mu: 1.5, sig: 0.5)))
		graph.nodes[next]?.value.updateConnectedness(node: graph.nodes[next]!)
	}
	newAgent.updateConnectedness(node: graph.nodes[newAgent.hashValue]!)
}

// generate social network
for i in 0..<n {
	var newAgent = Agent(id: tmpc.next()!, age: getAge(with: rand.nextProb() * 100.0))
	newAgent.randomize()
	_ = graph.addNode(withValue: newAgent)
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

var changes = [()->Void]()

// run the model
let days = 365
var crimeCounts: [(Int, Int, Int, Int, Int)] = []
var totalTime = 0
let threadGroup = DispatchGroup()
let threadQueue = DispatchQueue.global()

for d in 0..<days {
    tic()

	var record = Record(0, 0, 0, 0, 0)
	var cnt = graph.nodes.count
	if cnt == 0 {
		break
	}
	var hap = graph.nodes.values.map({$0.value.cma.pleasure}).reduce(0.0, +)/Float(graph.nodes.count + 1)

	let list = graph.nodes.map({ $0.value })
	let stride = Int(ceil(Float(cnt) / Float(THREAD_COUNT)))

	let sublists = list.chunks(stride)
	var subresults = [([()->Void], Record)]()

	threadGroup.wait()
	for sublist in sublists {
		subresults.append(([], Record(0, 0, 0, 0, 0)))
		let i = subresults.count - 1
		threadGroup.enter()
		threadQueue.async {{ (rand: Random) in
			subresults[i] = updateNodes(sublist, within: graph)
			threadGroup.leave()
		}(rand)}
	}
	threadGroup.wait() // Wai for all threads to finish

	for subresult in subresults {
		changes += subresult.0
		record += subresult.1
	}

	for change in changes {
		change()
	}
	changes = [()->Void]()

	// Birth new children!
	if Double(graph.nodes.count) * BIRTH_RATE >= 1 {
		for i: Int in 1...Int(Double(graph.nodes.count) * BIRTH_RATE) {
			addBaby(to: graph)
		}
	} else {
		if rand.next(prob: Float(graph.nodes.count) * Float(BIRTH_RATE)) {
			addBaby(to: graph)
		}
	}

	record.2 = cnt
	record.3 = Int(hap + 50)
	record.4 = (record.0 + record.1) * 100 / cnt
	crimeCounts += [record]
    //print(record)
    totalTime += toc()
}

print("Average time for one day: \(Float(totalTime)/1000000000/Float(days))s")

//print(crime_counts)

try NSString(string: String(describing: crimeCounts)).write(toFile: "out.txt", atomically: false, encoding: 2)