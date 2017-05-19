import Foundation
import Util

// Data source: http://data.worldbank.org/indicator/SP.DYN.CBRT.IN?end=2015&locations=US&start=1960&view=chart
// Recalculated per person and day
let BIRTH_RATE = 0.000033973

let n = 1000//998

var graph = Graph<Agent>(seed: rand.next())
var tmpc = Counter(0)

//                  Population, happiness, Murder rate, Crime rate, Gun murder rate,
typealias Record = (Int,        Float,     Float,       Float,      Float,
    //  Gun crime rate, avg connectedness
    Float,          Float)

infix operator +=
func +=(left: inout Record, right: Record) {
    left.0 += right.0
    left.1 += right.1
    left.2 += right.2
    left.3 += right.3
    left.4 += right.4
    left.5 += right.5
    left.6 += right.6
}

func deviation(of rec: Record, last: Record) -> Float {
    var ret = ((rec.3 / Float(rec.0)) * 100000.0 - 1.020821918)^^4 // Violent crime rate
    ret += (((rec.5 / Float(rec.0)) * 100000.0 - 0.28051726)^^5) // Firearm crime rate
    ret += ((Float(rec.0-last.0) / Float(rec.0) * 100000.0)^^2) // Population change
    return ret
}

// Open graph input file
let input = read("/Users/Administrator/stud/GESS/ABM/snap/gplus_small.txt")
let inList = input.characters.split{ $0 == " " || $0 == "\n" }.map{String($0)}

func updateNodes(_ nodeList: [GraphNode<Agent>], within graph: Graph<Agent>)
    -> Record {
        var record = Record(0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        
        for node in nodeList {
            
            let agent = node.value
            // Kill agent if too old
            if rand.nextProb() < deathProb(age: agent.age) {
                //print("death")
                graph.removeNode(node: node)
                for edge in node.edges.values {
                    edge.next.value.updateConnectedness(node: edge.next)
                }
            } else {
                if agent.emotion.dominance < -5 && canBuyGun(agent){
                    agent.ownsGun = true
                }
                
                let generator = CrimeGenerator(initiator: agent)
                /*
                 // for testing:
                 var extGun = generator.getExtend(gun: true)
                 extGun = extGun > 10 ? 10 : extGun
                 var extNoGun = generator.getExtend(gun: false)
                 extNoGun = extNoGun > 10 ? 10 : extNoGun
                 if extGun > 0 {
                 print("Visualized change for extend \(extGun) using gun: \(generator.visualizedChange(e: extGun, g: true))")
                 }
                 if extNoGun > 0 {
                 print("Visualized change for extend \(extNoGun): \(generator.visualizedChange(e: extNoGun, g: false))")
                 }
                 */
                if graph.nodes.count > 1, let decision = generator.makeDecision() {
                    print(decision.0)
                    if decision.1 {
                        record.2 += 1
                    }
                    record.3 += 1
                    var vicNode = GraphNode<Agent>(value: agent)
                    repeat {
                        vicNode = graph.getRandomNode()!
                    } while vicNode.value == agent
                    if generator.executeCrime(on: vicNode, with: decision.0, gun: decision.1) {
                        record.4 += 1
                    }
                }
                record.6 += Float(agent.connectedness)
                
                // Now get your friends and have a party
                var peers = [GraphNode<Agent>]() // Your m8s
                while rand.next(prob: 0.5) {
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
                if graph.find(hash: node.hashValue) != nil { // You dead yet?
                    for peer in peers {
                        if graph.find(hash: peer.hashValue) != nil { // Is your buddy still alive?
                            let oldWeight = node.getEdgeWeight(to: peer)
                            let newWeight = oldWeight == 0 ? 1.1 : rand.nextProb() * oldWeight / 10 // Up to 10% increase
                            graph.addEdge(from: node.hashValue, to: peer.hashValue, weight: newWeight)
                            peer.value.updateConnectedness(node: peer)
                        }
                    }
                    for edge in node.edges.values {
                        let weight = edge.weight - 0.05 // 0.1 decay per day
                        if weight < 0 {
                            graph.removeEdge(from: node.hashValue, to: edge.hashValue)
                        } else {
                            graph.addEdge(from: node.hashValue, to: edge.hashValue, weight: -0.1)
                            edge.next.value.updateConnectedness(node: edge.next)
                        }
                    }
                    agent.updateConnectedness(node: node)
                    // Unknown parameters: first weight, weight decay, weight increase, meeting probability
                }
                
                var newMoral: Double = 0.0
                var totalWeight: Double = 0.0
                if node.edges.count > 0 {
                    for nextAgent in node.edges {
                        // Influence on moral beliefs from agent's neighbors in social network
                        newMoral += (nextAgent.value.next.value.moral + nextAgent.value.weight^^2)
                        totalWeight += (nextAgent.value.weight^^2)
                    }
                    // Age factor: The older the agent the less likely he is to change his beliefs
                    let oldFac = ((agent.age == 0) ? 0 : (1.0 - (1.0 / Double(agent.age + 1)) + 0.1))
                    newMoral = (1.0 - oldFac) * newMoral / Double(node.edges.count) + oldFac * agent.moral
                    agent.moral = newMoral
                }
                
                // bring a bit movement into the people
                agent.moral += rand.nextNormal(mu: 0, sig: 0.2)
                agent.age += 1
                agent.updateConnectedness(node: node)
            }
        }
        
        return record
}

func addBaby(to graph: Graph<Agent>, with pars: Parameters) {
    //print("birth")
    let newAgent = Agent(tmpc.next()!)
    newAgent.randomize(pars)
    let newNode = graph.addNode(withValue: newAgent)
    for _ in 1...3 {
        if let next = graph.getRandomNode() {
            graph.addEdge(from: newNode.hashValue, to: next.hashValue,
                          weight: rand.nextNormal(mu: 1.5, sig: 0.5))
            next.value.updateConnectedness(node: next)
        }
    }
    newAgent.updateConnectedness(node: graph.find(hash: newAgent.hashValue)!)
}

// Runs the simulation with the given parameters for the given number of days and returns the
// deviation from empirical data
func runSimulation(_ pars: Parameters, days: Int = 365) -> Float {
    // Reset environment variables
    rand = Random(13579)
    tmpc = Counter(0)
    
    // Insert nodes from input
    graph = Graph<Agent>(seed: rand.next())
    var loadedNodes = [String:Int]()
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
    }
    //print("\(graph.nodes.count) Agents are entering the matrix...")
    
    // generate social network
    /*for i in 0..<n {
     var newAgent = Agent(id: tmpc.next()!, age: getAge(with: rand.nextProb() * 100.0))
     newAgent.randomize()
     _ = graph.addNode(withValue: newAgent)
     }
     
     for i in 0...3*n {
     var fst = Int(rand.next()%n)
     var snd = Int(rand.next()%n)
     graph.addEdge(from: fst, to: snd, weight: Float(rand.nextNormal(mu: 1.0)))
     }*/
    
    for i in 0..<n {
        let node = graph.find(hash: i)
        node?.value.updateConnectedness(node: node!)
    }
    
    
    // run the model
    var crimeCounts: [Record] = []
    var totalTime = 0
    
    for _ in 0..<days {
        tic()
        
        var record = Record(0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        let cnt = graph.nodes.count
        if cnt == 0 {
            break
        }
        let hap = graph.nodes.values.map({$0.value.emotion.pleasure}).reduce(0.0, +)/Double(graph.nodes.count + 1)
        
        let list = graph.nodes.map({ $0.value })
        
        record += updateNodes(list, within: graph)
        
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
        record.1 = Float(hap + 50.0)
        record.2 = record.2 * 100.0 / Float(cnt)
        record.3 = record.3 * 100.0 / Float(cnt)
        record.4 = record.4 * 100.0 / Float(cnt)
        record.5 = record.5 * 100.0 / Float(cnt)
        record.6 = record.6 / Float(cnt)
        crimeCounts += [record]
        //print(record)
        totalTime += toc()
    }
    
    // Calculate the goodness/badness value as sum of differences squared
    var badness = Float(0.0)
    var last = crimeCounts[0]
    for rec in crimeCounts {
        badness += deviation(of: rec, last: last)
        last = rec
    }
    
    //print("Average time for one day: \(Float(totalTime)/1000000000/Float(days))s")
    
    //print(crime_counts)
    
    try? NSString(string: String(describing: crimeCounts)).write(toFile: "out.txt", atomically: false, encoding: 2)
    
    return badness
}
