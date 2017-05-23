import Foundation
import Util

var EDGE_DECAY = 0.001 // TODO: Independent variable?
var INITIAL_EDGE_WEIGHT = 1.1

// Data source: http://data.worldbank.org/indicator/SP.DYN.CBRT.IN?end=2015&locations=US&start=1960&view=chart
// Recalculated per person and day
let BIRTH_RATE = 0.000033973
let RAND_SEED = 13579

var graph = Graph<Agent>(seed: rand.current)

extension Graph where T: Agent {
    func addEdge(from fst: GraphNode<T>, to snd: GraphNode<T>, weight: Double) {
        assert(nodes.has(staticHash: fst.hashValue) && nodes.has(staticHash: snd.hashValue))
        add_edge(from: fst, to: snd, weight: weight)
        let con = Agent.conVal(from: weight)
        fst.value.connectedness += con
        snd.value.connectedness += con
    }

    func removeEdge(from fst: GraphNode<T>, to snd: GraphNode<T>) {
        assert(fst.edges[snd.hashValue] != nil && snd.edges[fst.hashValue] != nil)
        let edge = remove_edge(from: fst, to: snd)! // assume edge is in graph
        let con = Agent.conVal(from: edge.weight)
        fst.value.connectedness -= con
        snd.value.connectedness -= con
        assert(fst.edges[snd.hashValue] == nil && snd.edges[fst.hashValue] == nil)
    }

    func removeNode(node: GraphNode<T>) {
        for edge in node.edges.values {
            removeEdge(from: node, to: edge.next)
        }
        nodes.remove(node)
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

func storeGraph(to file: URL = URL(fileURLWithPath: "graph.txt")) {
    var header = ""
    header += "\(rand.current)\n"
    header += "\(graph.nodes.rand.current)\n"
	header += "\(counter.cur)\n"
    var agentContent = ""
    var edgeContent = ""
    for node in graph.nodes {
        let agent = node.value.value
        agentContent += "Agent:\n"
        agentContent += "\(agent.hashValue)\n"
        agentContent += "\(agent.age)\n"
        agentContent += "\(agent.connectedness)\n"
        agentContent += "\(agent.criminalHistory)\n"
        agentContent += "\(agent.emotion.pleasure)\n"
        agentContent += "\(agent.emotion.arousal)\n"
        agentContent += "\(agent.emotion.dominance)\n"
        agentContent += "\(agent.moral)\n"
        agentContent += "\(agent.ownsGun)\n"

        for edge in node.value.edges {
            if !edge.value.next.value.visited {
                edgeContent += "Edge:\n"
                edgeContent += "\(node.value.hashValue)\n"
                edgeContent += "\(edge.value.next.hashValue)\n"
                edgeContent += "\(edge.value.weight)\n"
            }
        }

        node.value.value.visited = true
    }

    let content = header + agentContent + edgeContent
    try! content.write(to: file, atomically: false, encoding: .utf8)
    print("Graph data written")
}

func getGraphData(from file: URL = URL(fileURLWithPath: "graph.txt")) throws -> [String] {
    let content = try String(contentsOf: file, encoding: .utf8)
    return content.characters.split(separator: "\n").map(String.init)
}

func loadGraph(from file: URL = URL(fileURLWithPath: "graph.txt"), withSeed s: Bool = true, data: [String]? = nil) throws -> Graph<Agent> {
    let array = data == nil ? try getGraphData(from: file) : data!

    var i = 0

    let seed1 = Int(array[i])!
    let seed2 = Int(array[i+1])!
	let count = Int(array[i+1])!
    if s {
        rand = Random(seed1)
		counter = Counter(count)
    }
    let g = s ? Graph<Agent>(seed: seed2) : Graph<Agent>(seed: rand.next())
    i += 3

    while i < array.count {
        if array[i] == "Agent:" {
            let a = Agent(Int(array[i+1])!, age: Int(array[i+2])!)
            a.connectedness = Double(array[i+3])!
            a.criminalHistory = Bool(array[i+4])!
            a.emotion = Emotion(Double(array[i+5])!, Double(array[i+6])!, Double(array[i+7])!)
            a.moral = Double(array[i+8])!
            a.ownsGun = Bool(array[i+9])!
            g.addNode(withValue: a)
            i += 10
        } else if array[i] == "Edge:" {
            let startHash = Int(array[i+1])!
            let start = g.nodes.get(staticHash: startHash)!
            let endHash = Int(array[i+2])!
            let end = g.nodes.get(staticHash: endHash)!
            g.add_edge(from: start, to: end, weight: Double(array[i+3])!)
            i += 4
        } else {
            print("Couldn't read line: \(array[i])")
            i += 1
        }
    }
    print("Done loading graph")
    return g
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
			//print("death for age: \(agent.age)")
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
				if rand.next(prob: 0.8) && node.edges.count > 0 {
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
    let newAgent = Agent(tmpc.next()!, age: 0)
    newAgent.randomize(pars)
    let newNode = graph.addNode(withValue: newAgent)
    for _ in 1...3 {
        if let next = graph.getRandomNode() {
            graph.addEdge(from: newNode, to: next, weight: rand.nextNormal(mu: 1.5, sig: 0.5))
        }
    }
}

func newKids(pop: Int) -> Int {
    let newGuys = Double(pop) * BIRTH_RATE
    return Int(newGuys) + ((rand.nextProb() < newGuys - floor(newGuys)) ? 1 : 0)
}

// Runs the simulation with the given parameters for the given number of days and returns the
// deviation from empirical data
@discardableResult
func runSimulation(ageDist: [(Int, Bool)], _ pars: Parameters, days: Int = 365, write: Bool = true, g: Graph<Agent>? = nil) -> Double {

	// Apply parameters for crime generator
	CrimeGenerator.baseGain = pars.4
	CrimeGenerator.baseCost = pars.5
	CrimeGenerator.maxDecExt = pars.9
	CrimeGenerator.incGun = pars.10

	// Apply edge based parameters
	INITIAL_EDGE_WEIGHT = pars.7
	EDGE_DECAY = pars.8

    if g == nil {
		// Reset environment variables
		rand = Random(RAND_SEED)

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
        
        for person in ageDist {
            if person.1 {
                let newAgent = Agent(counter.next()!, age: person.0)
                newAgent.randomize(pars)
                _ = graph.addNode(withValue: newAgent)
                //print("Age: \(Double(person.0)/365.0)")
            }
        }

        for _ in 0...pars.6/2*graph.nodes.count {
            let fst = graph.getRandomNode()!
            let snd = graph.getRandomNode()!
            graph.addEdge(from: fst, to: snd, weight: rand.nextNormal(mu: 1.0))
        }
    } else {
        graph = g!
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
        var realNewGuys = newKids(pop: graph.nodes.count)
		while realNewGuys > 0 {
			addBaby(to: graph, with: pars)
			realNewGuys -= 1
		}

		record.0 = cnt
		record.1 = Double(hap + 50.0)
		record.2 = record.2 * 100.0 / Double(cnt)
		record.3 = record.3 * 100.0 / Double(cnt)
		record.4 = record.4 / Double(cnt)
		record.5 = record.5 / Double(cnt) * 100.0
		crimeCounts += [record]
	    //print(record)
        let emojiRand = rand.nextProb()
        let emoji = emojiRand < 0.2 ? "🕶" : emojiRand < 0.4 ? "🦋" : emojiRand < 0.6 ? "💰" : emojiRand < 0.8 ? "🤠" : "🥊"
		//print(emoji, terminator:"  ")
		fflush(stdout)
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
	avgBadness += ((popChange/Double(days) - 2.14794520548)^^2)
	avgBadness += ((crimes/Double(days) - 1.020821918)^^2)
	avgBadness += ((gunCrimes/Double(days) - 0.28051726)^^2)
	badness += (avgBadness^^5)

	//print("Average time for one day: \(Double(totalTime)/1000000000/Double(days))s")

	//print(crime_counts)

	if write {
		try? NSString(string: String(describing: crimeCounts)).write(toFile: "out.txt", atomically: false, encoding: 2)
		print(" Violent crimes committed: \(crimeCnt)")
        storeGraph(to: URL(fileURLWithPath: "graph.txt"))
	}

	return badness
}
