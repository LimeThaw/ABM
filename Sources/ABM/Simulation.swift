import Foundation
import Util

var EDGE_DECAY = 0.001 // TODO: Independent variable?
var INITIAL_EDGE_WEIGHT = 1.1

// Data source: http://data.worldbank.org/indicator/SP.DYN.CBRT.IN?end=2015&locations=US&start=1960&view=chart
// Recalculated per person and day
let BIRTH_RATE = 0.000033973
let RAND_SEED = 13579

var graph = Graph<Agent>(seed: rand.next())

extension Graph where T: Agent {
    func addEdge(from fst: GraphNode<T>, to snd: GraphNode<T>, weight: Double) {
        add_edge(from: fst, to: snd, weight: weight)
        let con = Agent.conVal(from: weight)
        fst.value.connectedness += con
        snd.value.connectedness += con
    }

    func removeEdge(from fst: GraphNode<T>, to snd: GraphNode<T>) {
        let edge = remove_edge(from: fst, to: snd)! // assume edge is in graph
        let con = Agent.conVal(from: edge.weight)
        fst.value.connectedness -= con
        snd.value.connectedness -= con
    }

    func removeNode(node: GraphNode<T>) {
        if nodes.remove(node) != nil {
            for edge in node.edges.values {
                removeEdge(from: node, to: edge.next)
            }
        }
    }
}

var tmpc = Counter(0)

// Records interesting values for one day
typealias Record = (
	Int,		// Population
	Double,		// happiness
	Double,		// Crime rate
	Double,		// Gun crime rate
	Double,		// Average connectedness
	Double		// Gun possession rate
)

infix operator +=
func +=(left: inout Record, right: Record) {
	left.0 += right.0
	left.1 += right.1
	left.2 += right.2
	left.3 += right.3
	left.4 += right.4
	left.5 += right.5
}

func deviation(of rec: Record, last: Record) -> Double {
	var ret = ((rec.2 / Double(rec.0)) * 100000.0 - 1.020821918)^^2 // Violent crime rate
	ret += (((rec.3 / Double(rec.0)) * 100000.0 - 0.28051726)^^2) // Firearm crime rate
	ret += ((Double(rec.0-last.0) / Double(rec.0) * 100000.0 - 214.794520548)^^2) // Population change
	return ret
}

// Open graph input file
let input = read("/Users/Administrator/stud/GESS/ABM/snap/gplus_small.txt")
let inList = input.characters.split{ $0 == " " || $0 == "\n" }.map{String($0)}

func updateNodes(_ nodeList: [GraphNode<Agent>], within graph: Graph<Agent>, generator rand: inout Random)
		-> ([() -> Void], Record) {

	var changes = [() -> Void]()
	var record = Record(0, 0.0, 0.0, 0.0, 0.0, 0.0)

	for node in nodeList {

		let agent = node.value

		// Validate agent atttibutes
		agent.checkAttributes()

		// Check if agent owns a gun
		if agent.ownsGun {
			record.5 += 1.0
		}

		// Kill agent if too old
		if rand.nextProb() < deathProb(age: agent.age) {
			//print("death")
			changes.append({
				graph.removeNode(node: node)
			})
		} else {
			if agent.emotion.dominance < -5 && canBuyGun(agent){
	            changes.append{ agent.ownsGun = true }
	        }

	        let generator = CrimeGenerator(initiator: agent, generator: rand.duplicate())
	        if graph.nodes.count > 1, let decision = generator.makeDecision() {
				record.2 += 1.0
				if decision.1 {
					record.3 += 1.0
				}
	            var vicNode = GraphNode<Agent>(value: agent)
	            repeat {
	                vicNode = graph.getRandomNode()!
	            } while vicNode.value == agent
	            changes.append {generator.executeCrime(on: vicNode, with: decision.0, gun: decision.1)}
	        }
			record.4 += Double(agent.connectedness)

			// Now get your friends and have a party
			var peers = [GraphNode<Agent>]() // Your m8s
			let aFac = (agent.emotion.arousal - attributeBound.0) / (attributeBound.1 - attributeBound.0)
			while rand.next(prob: 0.1*aFac) {
				// Who do you wanna invite?
				if rand.next() && node.edges.count > 0 {
					// Your friends?
					let ind = rand.next(max: node.edges.count)
					peers.append(node.edges[node.edges.index(node.edges.startIndex, offsetBy: ind)].value.next)
				} else {
					// Or some hot chicks?
					peers.append(graph.getRandomNode()!)
				}
			}
			// Now let's get RIGGITY RIGGITY REKT SON!

			for peer in peers {
				let oldWeight = node.getEdgeWeight(to: peer)
				let weightIncrease = rand.nextProb() * oldWeight / 10 // Up to 10% increase
				let newWeight = oldWeight == 0 ? INITIAL_EDGE_WEIGHT : weightIncrease
				changes.append {
                    if graph.find(hash: node.hashValue) != nil && graph.find(hash: peer.hashValue) != nil {
						graph.addEdge(from: node, to: peer, weight: newWeight)
					}
				}
			}
			for edge in node.edges.values {
				let weight = edge.weight - EDGE_DECAY
				changes.append {
					if graph.find(hash: node.hashValue) != nil && node.edges[edge.hashValue] != nil {
						if weight < 0 {
							graph.removeEdge(from: node, to: edge.next)
						} else {
							graph.addEdge(from: node, to: edge.next, weight: -EDGE_DECAY)
						}
					}
				}
			}

			var newMoral: Double = 0.0
            if node.edges.isEmpty {
                newMoral = agent.moral
            } else {
                var totalWeight: Double = 0.0
                for nextAgent in node.edges {
                    // Influence on moral beliefs from agent's neighbors in social network
                    newMoral += (nextAgent.value.next.value.moral + nextAgent.value.weight^^2)
                    totalWeight += (nextAgent.value.weight^^2)
                }
                // Age factor: The older the agent the less likely he is to change his beliefs
                let oldFac = ((agent.age == 0) ? 0 : (1.0 - (1.0 / Double(agent.age + 1)) + 0.1))
                newMoral = (1.0 - oldFac) * newMoral / Double(node.edges.count) + oldFac * agent.moral + rand.nextNormal(mu: 0, sig: 0.2)
            }

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
        if let next = graph.getRandomNode() {
            graph.addEdge(from: newNode, to: next, weight: rand.nextNormal(mu: 1.5, sig: 0.5))
        }
    }
}

// Runs the simulation with the given parameters for the given number of days and returns the
// deviation from empirical data
@discardableResult
func runSimulation(_ pars: Parameters, days: Int = 365, population n: Int = 100, write: Bool = true) -> Double {
	// Reset environment variables
	rand = Random(RAND_SEED)
	tmpc = Counter(0)

	// Apply parameters for crime generator
	CrimeGenerator.baseGain = pars.4
	CrimeGenerator.baseCost = pars.5
	CrimeGenerator.maxDecExt = pars.9
	CrimeGenerator.incGun = pars.10

	// Apply edge based parameters
	INITIAL_EDGE_WEIGHT = pars.7
	EDGE_DECAY = pars.8

	// Insert nodes from input
	graph = Graph<Agent>(seed: RAND_SEED)
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
        let fst = graph.getRandomNode()!
        let snd = graph.getRandomNode()!
        graph.addEdge(from: fst, to: snd, weight: rand.nextNormal(mu: 1.0))
	}

	var changes = [()->Void]()

	// run the model
	var crimeCounts: [Record] = []
	var totalTime = 0

	var badness = Double(0.0)

	simLoop: for _ in 0..<days {
	    tic()

		var record = Record(0, 0.0, 0.0, 0.0, 0.0, 0.0)
		let cnt = graph.nodes.count
		if cnt == 0 {
			//print("💀", terminator: "")
			badness = Double.infinity
			break simLoop
		}
		let hap = graph.nodes.values.map({$0.value.emotion.pleasure}).reduce(0.0, +)/Double(graph.nodes.count + 1)

		let list = graph.nodes.map({ $0.value })

		var newRand = rand.duplicate()
		let subresult = updateNodes(list, within: graph, generator: &newRand)
		changes += subresult.0
		record += subresult.1

		for change in changes {
			change()
		}
		changes = [()->Void]()

		// Birth new children!
		var newGuys = Double(graph.nodes.count) * BIRTH_RATE
		while newGuys >= 1 {
			addBaby(to: graph, with: pars)
			newGuys -= 1.0
		}
		if rand.next(prob: newGuys) {
			addBaby(to: graph, with: pars)
		}

		record.0 = cnt
		record.1 = Double(hap + 50.0)
		record.2 = record.2 * 100.0 / Double(cnt)
		record.3 = record.3 * 100.0 / Double(cnt)
		record.4 = record.4 / Double(cnt)
		record.5 = record.5 / Double(cnt) * 100.0
		crimeCounts += [record]
	    //print(record)
	    totalTime += toc()
	}

	// Calculate the goodness/badness value as sum of differences squared
	var last = crimeCounts[0]
	var popChange = 0.0, crimes = 0.0, gunCrimes = 0.0, crimeCnt = 0.0
	for rec in crimeCounts {
		badness += deviation(of: rec, last: last)
		popChange += abs(Double(rec.0-last.0) / Double(rec.0) * 100000.0)
		crimes += abs((rec.2 / Double(rec.0)) * 100000.0 - 1.020821918)
		crimeCnt += rec.2
		gunCrimes += abs(rec.3 / Double(rec.0) * 100000.0 - 0.28051726)
		last = rec
	}
	badness = badness/Double(crimeCounts.count)
	if crimeCnt == 0.0 {
		badness = Double.infinity
	}
	var avgBadness = 0.0
	avgBadness += ((popChange/Double(days) - 214.794520548)^^2)
	avgBadness += ((crimes/Double(days) - 1.020821918)^^2)
	avgBadness += ((gunCrimes/Double(days) - 0.28051726)^^2)
	badness += (avgBadness^^2)

	//print("Average time for one day: \(Double(totalTime)/1000000000/Double(days))s")

	//print(crime_counts)

	if write {
		try? NSString(string: String(describing: crimeCounts)).write(toFile: "out.txt", atomically: false, encoding: 2)
		print(" Violent crimes committed: \(crimeCnt)")
	}

	return badness
}
