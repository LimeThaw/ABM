import Foundation
import Util

var EDGE_DECAY = 0.001
var INITIAL_EDGE_WEIGHT = 1.1

// Data source: http://data.worldbank.org/indicator/SP.DYN.CBRT.IN?end=2015&locations=US&start=1960&view=chart
// Recalculated per person and day
let BIRTH_RATE = 0.000033973
let RAND_SEED = 13579

var graph = Graph<Agent>(seed: rand.current)

// Records interesting values for one day
typealias Record = (
	population:		Int,		// Population
	happiness:		Double,		// happiness
	crimeRate:		Double,		// Crime rate
	gunCrimeRate:	Double,		// Gun crime rate
	gunPossession:	Double		// Gun possession rate
)

// Operator for adding records
infix operator +=
func +=(left: inout Record, right: Record) {
	left.0 += right.0
	left.1 += right.1
	left.2 += right.2
	left.3 += right.3
	left.4 += right.4
}

// Runs the simulation with the given parameters for the given number of days and returns the
// deviation from empirical data
@discardableResult
func runSimulation(_ pars: Parameters, days: Int = 365, population n: Int = 100, write: Bool = true, g: Graph<Agent>? = nil, ages: [Int]? = nil) -> Double {

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
		counter = Counter(0)

        // Insert nodes from input
        graph = Graph<Agent>(seed: RAND_SEED)

        // generate social network
		let ageDist = ages == nil ? getAgeDist(n) : ages!
		for age in ageDist {
            let newAgent = Agent(counter.next()!, age: age)
            newAgent.randomize(pars)
            _ = graph.addNode(withValue: newAgent)

		}

        for _ in 0...pars.6/2*n {
            let fst = graph.getRandomNode()!
            let snd = graph.getRandomNode()!
            graph.addEdge(from: fst, to: snd, weight: rand.nextNormal(mu: 1.0))
        }
    } else {
        graph = g!
    }

	// Initializing the list of agent and graph updates to be executed later
	var changes = [()->Void]()
	var crimeCounts: [Record] = []
	var totalTime = 0

	// The badness value used for ranking parameter sets
	var badness = Double(0.0)

	// Main simulation loop
	simLoop: for _ in 0..<days {
	    tic()

		// Initializing record values
		var record = Record(0, 0.0, 0.0, 0.0, 0.0)
		let cnt = graph.nodes.count
		let hap = graph.nodes.values.map({$0.value.emotion.pleasure}).reduce(0.0, +)/Double(graph.nodes.count + 1)

		// If all agents are gone there is no point in continuing the simulation
		if cnt == 0 {
			badness = Double.infinity
			break simLoop
		}

		let list = graph.nodes.map({ $0.value }) // The list of all agents

		// This is the actual meat of the simulation - see NodeUpdate.swift for more
		let subresult = updateNodes(list, within: graph, generator: &rand)

		// Remember the records and the changes to be executed later
		changes += subresult.0
		record += subresult.1

		// Apply changes received from decision making
		for change in changes {
			change()
		}
		// Reset list of pending changes
		changes = [()->Void]()

		// Birth new children!
		var newGuys = newKids(pop: graph.nodes.count)
		while newGuys > 0 {
			addBaby(to: graph, with: pars)
			newGuys -= 1
		}

		// Perform some post-calculations and normalizations on the output
		record.0 = cnt
		record.1 = Double(hap + 50.0)
		record.2 = record.2 * 100.0 / Double(cnt)
		record.3 = record.3 * 100.0 / Double(cnt)
		record.4 = record.4 / Double(cnt) * 100.0
		crimeCounts += [record] // Add to overall result

		// Print a pretty dot so we know we make progress
		print(".", terminator:"")
		fflush(stdout)

	    totalTime += toc()
	}

	// Calculate the goodness/badness value as sum of differences squared
	badness = deviation(of: crimeCounts)

	// How good is our performance?
	print("Average time for one day: \(Double(totalTime)/1000000000/Double(days))s")
    storeGraph(graph, to: URL(fileURLWithPath: "graph.txt"))

	// Write the simulation result to file "out.txt"
	if write {
		try? NSString(string: String(describing: crimeCounts)).write(toFile: "out.txt", atomically: false, encoding: 2)
	}

	// Return badness value for ranking of parameter sets
	return badness
}
