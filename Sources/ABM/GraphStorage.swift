import Foundation
import Util

func storeGraph(_ graph: Graph<Agent>, to file: URL) {
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
}

func loadGraph(from file: URL, withSeed s: Bool = true) throws -> Graph<Agent> {
    let content = try String(contentsOf: file, encoding: .utf8)
    let array = content.characters.split(separator: "\n").map(String.init)

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