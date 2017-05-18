import Foundation
import Util
import Dispatch

let THREAD_COUNT = 4

let n = 111//998

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
        
        if agent.emotion.dominance < -5 && canBuyGun(agent){
            agent.ownsGun = true
        }
        
        let generator = CrimeGenerator(initiator: agent)
        if let decision = generator.makeDecision() {
            var vicNode = GraphNode<Agent>(value: agent)
            repeat {
                let next = rand.next(max: graph.nodes.count)
                vicNode = graph.getNode(index: next)!
            } while vicNode.value != agent
            changes.append {generator.executeCrime(on: vicNode, with: decision.0, gun: decision.1)}
        }
	}

	return (changes, record)
}

// generate social network
for i in 0..<n {
	var newAgent = Agent(tmpc.next()!)
    newAgent.moral = rand.nextNormal(mu: Double(newAgent.moral), sig: 2.0)
	/*if Random.get_next() % 100 <= 5 { // Person is unemployed
		new_agent.daily_income = 15
	}*/
    if rand.next(prob: 0.3225) { // Person owns a firearm
		newAgent.ownsGun = true
	}
	newAgent.age = getAge(with: rand.nextProb() * 100.0)

	graph.addNode(withValue: newAgent)
}

for i in 0...3*n {
	var fst = Int(rand.next()%n)
	var snd = Int(rand.next()%n)
	graph.addEdge(from: fst, to: snd, weight: rand.nextNormal(mu: 1.0))
}

for i in 0..<n {
	var node = graph.find(hash: i)
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
	var hap = graph.nodes.values.map({$0.value.emotion.pleasure}).reduce(0.0, +)/Double(graph.nodes.count + 1)

	let list = graph.nodes.map({ $0.value })
	let stride = Int(ceil(Float(cnt) / Float(THREAD_COUNT)))

	let sublists = list.chunks(stride)
	var subresults = [([()->Void], Record)]()

	threadGroup.wait()
	for sublist in sublists {
		subresults.append(([], Record(0, 0, 0, 0, 0)))
		let i = subresults.count - 1
		threadGroup.enter()
		threadQueue.async {
			subresults[i] = updateNodes(sublist, within: graph)
			threadGroup.leave()
		}
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

	record.2 = cnt
	record.3 = Int(hap + 50)
	record.4 = (record.0 + record.1) * 100 / cnt
	crimeCounts += [record]
    //print(entry)
    totalTime += toc()
}

print("Average time for one day: \(Float(totalTime)/1000000000/Float(days))s")

//print(crime_counts)

try NSString(string: String(describing: crimeCounts)).write(toFile: "out.txt", atomically: false, encoding: 2)
