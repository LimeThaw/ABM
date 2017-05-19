import Foundation
import Util
import Dispatch

let EDGE_DECAY = 0.1 // TODO: Independent variable?
let INITIAL_EDGE_WEIGHT = 1.1

let THREAD_COUNT = 1
// Data source: http://data.worldbank.org/indicator/SP.DYN.CBRT.IN?end=2015&locations=US&start=1960&view=chart
// Recalculated per person and day
let BIRTH_RATE = 0.000033973

var graph = Graph<Agent>()
var tmpc = Counter(0)

//                  Population, happiness, Crime rate, Gun crime rate, avg connectedness
typealias Record = (Int,        Double,    Double,     Double,         Double)

infix operator +=
func +=(left: inout Record, right: Record) {
	left.0 += right.0
	left.1 += right.1
	left.2 += right.2
	left.3 += right.3
	left.4 += right.4
}

func deviation(of rec: Record, last: Record) -> Double {
	var ret = ((rec.2 / Double(rec.0)) * 100000.0 - 1.020821918)^^2 // Violent crime rate
	ret += (((rec.3 / Double(rec.0)) * 100000.0 - 0.28051726)^^2) // Firearm crime rate
	ret += ((Double(rec.0-last.0) / Double(rec.0) * 100000.0)^^2) // Population change
	// FIXME: No comparison for popChange
	return ret
}

// Open graph input file
let input = read("snap/gplus_med.txt")
let inList = input.characters.split{ $0 == " " || $0 == "\n" }.map{String($0)}

func updateNodes(_ nodeList: [GraphNode<Agent>], within graph: Graph<Agent>, generator rand: inout Random)
		-> ([() -> Void], Record) {

	var changes = [() -> Void]()
	var record = Record(0, 0.0, 0.0, 0.0, 0.0)

	for node in nodeList {

		let agent = node.value
		// Validate agent atttibutes
		agent.checkAttributes()

		// Kill agent if too old
		if rand.nextProb() < deathProb(age: agent.age) {
			//print("death")
			changes.append({
				graph.removeNode(node: node)
				for edge in node.edges.values {
					edge.next.value.updateConnectedness(node: edge.next)
				}
			})
		} else {
			if agent.emotion.dominance < -5 && canBuyGun(agent){
	            agent.ownsGun = true
	        }

	        let generator = CrimeGenerator(initiator: agent, generator: rand.duplicate())
	        if let decision = generator.makeDecision() {
				record.2 += 1.0
				if decision.1 {
					record.3 += 1.0
				}
	            var vicNode = GraphNode<Agent>(value: agent)
	            repeat {
	                let next = rand.next(max: graph.nodes.count)
	                vicNode = graph.getNode(index: next)!
	            } while vicNode.value != agent
	            changes.append {generator.executeCrime(on: vicNode, with: decision.0, gun: decision.1)} // FIXME: Rand usage?!
	        }
			record.4 += Double(agent.connectedness)

			// Now get your friends and have a party
			var peers = [GraphNode<Agent>]() // Your m8s
			let aFac = (agent.emotion.arousal - attributeBound.0) / (attributeBound.1 - attributeBound.0)
			while rand.next(prob: 0.9*aFac) {
				// Who do you wanna invite?
				if rand.next() && node.edges.count > 0 {
					// Your friends?
					let ind = rand.next(max: node.edges.count)
					peers.append(node.edges[node.edges.index(node.edges.startIndex, offsetBy: ind)].value.next)
				} else {
					// Or some hot chicks?
					let ind = rand.next(max: graph.nodes.count)
					peers.append(graph.nodes[graph.nodes.index(graph.nodes.startIndex, offsetBy: ind)].value)
				}
			}
			// Now let's get RIGGITY RIGGITY REKT SON!

			for peer in peers {
				let oldWeight = node.getEdgeWeight(to: peer)
				let weightIncrease = rand.nextProb() * oldWeight / 10 // Up to 10% increase
				let newWeight = oldWeight == 0 ? INITIAL_EDGE_WEIGHT : weightIncrease
				changes.append {
					if graph.nodes[node.hashValue] != nil && graph.nodes[peer.hashValue] != nil {
						graph.addEdge(from: node.hashValue, to: peer.hashValue, weight: newWeight)
						peer.value.updateConnectedness(node: peer)
					}
				}
			}
			for edge in node.edges.values {
				let weight = edge.weight - EDGE_DECAY
				changes.append {
					if graph.nodes[node.hashValue] != nil && graph.nodes[edge.hashValue] != nil {
						if weight < 0 {
							graph.removeEdge(from: node.hashValue, to: edge.hashValue)
						} else {
							graph.addEdge(from: node.hashValue, to: edge.hashValue, weight: -EDGE_DECAY)
							edge.next.value.updateConnectedness(node: edge.next)
						}
					}
				}
			}

			var newMoral: Double = 0.0
			var totalWeight: Double = 0.0
			for nextAgent in node.edges {
				// Influence on moral beliefs from agent's neighbors in social network
				newMoral += (nextAgent.value.next.value.moral + nextAgent.value.weight^^2)
				totalWeight += (nextAgent.value.weight^^2)
			}
			// Age factor: The older the agent the less likely he is to change his beliefs
			let oldFac = ((agent.age == 0) ? 0 : (1.0 - (1.0 / Double(agent.age + 1)) + 0.1))
			newMoral = (1.0 - oldFac) * newMoral / Double(node.edges.count) + oldFac * agent.moral + rand.nextNormal(mu: 0, sig: 0.2)

			changes.append({
				// bring a bit movement into the people
				agent.age += 1
				agent.moral = newMoral
			})
		}
	}

	return (changes, record)
}

func addBaby(to graph: Graph<Agent>, with pars: Parameters) {
	//print("birth")
	let newAgent = Agent(tmpc.next()!)
	newAgent.randomize(pars)
	let newNode = graph.addNode(withValue: newAgent)
	for _ in 1...3 {
		var next = Int(rand.next()%graph.nodes.count)
		next = [Int](graph.nodes.keys)[next]
		graph.addEdge(from: newNode.hashValue, to: next,
			weight: rand.nextNormal(mu: 1.5, sig: 0.5))
		graph.nodes[next]?.value.updateConnectedness(node: graph.nodes[next]!)
	}
	newAgent.updateConnectedness(node: graph.nodes[newAgent.hashValue]!)
}

// Runs the simulation with the given parameters for the given number of days and returns the
// deviation from empirical data
@discardableResult
func runSimulation(_ pars: Parameters, days: Int = 365, population n: Int = 100) -> Double {
	// Reset environment variables
	rand = Random(13579)
	tmpc = Counter(0)

	// Apply parameters for crime generator
	CrimeGenerator.baseGain = pars.4
	CrimeGenerator.baseCost = pars.5

	// Insert nodes from input
	graph = Graph<Agent>()
	/*var loadedNodes = [String:Int]()
	for i in 0..<(inList.count/2) {
		let one = inList[2*i]
		let two = inList[2*i+1]

		var oneId = loadedNodes[one]
		if oneId == nil {
			let newAgent = Agent(tmpc.next()!, age: getAge(with: rand.nextProb() * 100.0))
			newAgent.randomize(pars)
			oneId = graph.addNode(withValue: newAgent).hashValue
			loadedNodes[one] = oneId
		}

		var twoId = loadedNodes[two]
		if twoId == nil {
			let newAgent = Agent(tmpc.next()!, age: getAge(with: rand.nextProb() * 100.0))
			newAgent.randomize(pars)
			twoId = graph.addNode(withValue: newAgent).hashValue
			loadedNodes[two] = twoId
		}

		graph.addEdge(from: oneId!, to: twoId!, weight: rand.nextNormal(mu: 1.0))
		if graph.nodes.count >= n {
			break
		}
	}*/
	//print("\(graph.nodes.count) Agents are entering the matrix...")

	// generate social network
	for _ in 0..<n {
		let newAgent = Agent(tmpc.next()!, age: getAge(with: rand.nextProb() * 100.0))
		newAgent.randomize(pars)
		_ = graph.addNode(withValue: newAgent)
	}

	for _ in 0...pars.6/2*n {
		let fst = Int(rand.next()%n)
		let snd = Int(rand.next()%n)
		graph.addEdge(from: fst, to: snd, weight: rand.nextNormal(mu: 1.0))
	}

	for i in 0..<n {
		let node = graph.find(hash: i)
		node?.value.updateConnectedness(node: node!)
	}

	var changes = [()->Void]()

	// run the model
	var crimeCounts: [Record] = []
	var totalTime = 0
	let threadGroup = DispatchGroup()
	let threadQueue = DispatchQueue.global()

	var badness = Double(0.0)

	simLoop: for _ in 0..<days {
	    tic()

		var record = Record(0, 0.0, 0.0, 0.0, 0.0)
		let cnt = graph.nodes.count
		if cnt == 0 {
			//print("💀", terminator: "")
			badness = Double.infinity
			break simLoop
		}
		let hap = graph.nodes.values.map({$0.value.emotion.pleasure}).reduce(0.0, +)/Double(graph.nodes.count + 1)

		let list = graph.nodes.map({ $0.value })
		let stride = Int(ceil(Double(cnt) / Double(THREAD_COUNT)))

		let sublists = list.chunks(stride)
		var subresults = [([()->Void], Record)]()

		threadGroup.wait()
		for sublist in sublists {
			subresults.append(([], Record(0, 0.0, 0.0, 0.0, 0.0)))
			let i = subresults.count - 1
			threadGroup.enter()
			var newRand = rand.duplicate()
			threadQueue.async {{ (rand: Random) in
				subresults[i] = updateNodes(sublist, within: graph, generator: &newRand)
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
			for _: Int in 1...Int(Double(graph.nodes.count) * BIRTH_RATE) {
				addBaby(to: graph, with: pars)
			}
		} else {
			if rand.next(prob: Double(graph.nodes.count) * BIRTH_RATE) {
				addBaby(to: graph, with: pars)
			}
		}

		record.0 = cnt
		record.1 = Double(hap + 50.0)
		record.2 = record.2 * 100.0 / Double(cnt)
		record.3 = record.3 * 100.0 / Double(cnt)
		record.4 = record.4 / Double(cnt)
		crimeCounts += [record]
	    //print(record)
	    totalTime += toc()
	}

	// Calculate the goodness/badness value as sum of differences squared
	var last = crimeCounts[0]
	var popChange = 0.0, crimes = 0.0, gunCrimes = 0.0
	for rec in crimeCounts {
		//badness += deviation(of: rec, last: last)
		popChange += (Double(rec.0-last.0) / Double(rec.0) * 100000.0)
		crimes += ((rec.2 / Double(rec.0)) * 100000.0 - 1.020821918)
		gunCrimes += (rec.3 / Double(rec.0) * 100000.0 - 0.28051726)
		last = rec
	}
	badness += ((popChange/Double(days) - 214.794520548)^^2)
	badness += ((crimes/Double(days) - 1.020821918)^^2)
	badness += ((gunCrimes/Double(days) - 0.28051726)^^2)

	print("Average time for one day: \(Double(totalTime)/1000000000/Double(days))s")

	//print(crime_counts)

	try? NSString(string: String(describing: crimeCounts)).write(toFile: "out.txt", atomically: false, encoding: 2)

	return badness
}