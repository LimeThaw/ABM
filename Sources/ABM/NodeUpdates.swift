import Foundation
import Util

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