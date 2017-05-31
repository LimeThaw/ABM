import Foundation
import Util

class Agent : Hashable {

	let hashValue: Int // The unique ID of the agent
    var emotion: Emotion // The emotional state / temperament
    var moral: Double = 0 // The agent's moral value
	var age: Int = 0 // How old is our agent?
	// TODO: Does this need to be distributed at start?
	var criminalHistory = false // Has the agent ever committed a violent crime?
	// TODO: Do we want to keep this? Maybe useful output?
	var connectedness: Double = 0
	var ownsGun: Bool = false // Does the agent own a gun?

    /// A value that indicates whether this agent was already visited in a graph traversal
    var visited = false

	init(_ id: Int, age: Int) {
		hashValue = id
        emotion = Emotion()
		self.age = age
	}

	// Randomizes agent attributes to make them more heterogenous
	// Does not touch the age, you have to do that yourself.
	public func randomize(_ pars: Parameters) {
		moral = rand.nextNormal(mu: Double((pars.0).0), sig: Double((pars.0).1), range: attributeBound)
		emotion.pleasure = rand.nextNormal(mu: Double((pars.1).0), sig: Double((pars.1).1), range: attributeBound)
		emotion.arousal = rand.nextNormal(mu: Double((pars.2).0), sig: Double((pars.2).1), range: attributeBound)
		emotion.dominance = rand.nextNormal(mu: Double((pars.3).0), sig: Double((pars.3).1), range: attributeBound)

		if rand.next(prob: 0.3225) { // Does this guy get a gun?
			ownsGun = true
		} else {
			ownsGun = false
		}
	}

	// Returns the considered connectedness value for an edge with the given weight
    public static func conVal(from weight: Double) -> Double{
        return weight^^2
    }

	// Ensures that all attributes of the agents are within the imposed bounds
	func checkAttributes() {
		emotion.pleasure = clamp(emotion.pleasure, from: attributeBound.0, to: attributeBound.1)
		emotion.arousal = clamp(emotion.arousal, from: attributeBound.0, to: attributeBound.1)
		emotion.dominance = clamp(emotion.dominance, from: attributeBound.0, to: attributeBound.1)
		moral = clamp(moral, from: attributeBound.0, to: attributeBound.1)
	}

	// Compares Agent objects by comparing their hashValues
	static func ==(_ first: Agent, _ second: Agent) -> Bool {
		return first.hashValue == second.hashValue
	}
}

// Takes a Double between 0 and 100 as percentile, determines an age group and generates a random
// age in days within that group
// FIXME: Do we still need this?
func getAge(with variable: Double) -> Int {
	assert(0 <= variable && variable <= 100, "Please give a uniformly random float value in [0;100]")

	// Values from http://www.statsamerica.org/town/ for Wilmington, NC
	// Age groups: (Cumulative percentages (this group or younger), min age, max age)
	let ages = [
		(4.6, 0, 5),
		(18.0, 5, 18),
		(35.4, 18, 25),
		(61.8, 25, 45),
		(85.4, 45, 65),
		(100.0, 65, 100)
	]

	// The age group index
	var index = 0
	for age in ages {
		if age.0 > Double(variable) {
			break
		} else {
			index += 1
		}
	}

	let age = ages[index]
	// Return random age in days within age group
	return rand.next(max: (age.2 - age.1) * 365) + age.1 * 365
}

// TODO: Can we get a better method?
func deathProb(age: Int) -> Double {
	// Gives the probability that a person of given age dies today
	// Actually prob. that a RV ~N(79, 10) takes value age
	// Data from http://data.worldbank.org/indicator/SP.DYN.LE00.IN?end=2015&locations=US&start=1960&view=chart

	// 1/sqrt(2 PI sig^2)
	let coeff = 0.039894228040143267793994605993438186847585863116493465766
	// 2*sig^2
	let twoS2 = 200.0

	var exponent = Double(age)/365.0-79.0
	exponent *= exponent
	return coeff * exp(-Double(exponent)/twoS2)
}

// Add some useful functions to a graph if its nodes are agents
// Primarily takes care of connectedness automatically, saving computation time
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