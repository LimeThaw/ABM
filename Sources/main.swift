import Foundation

Random.set_seed(to: 12345)

let n = 1000

var graph = Graph<Agent>()
for i in 0..<n {
	var new_agent = Agent()
	new_agent.happiness = Float(Random.get_next_normal(mu: Double(new_agent.happiness), sig2: 0.5))
	/*if Random.get_next() % 100 <= 5 { // Person is unemployed
		new_agent.daily_income = 15
	}
	if Random.get_next() % 3 == 0 { // Person owns a firearm
		new_agent.owns_gun = true
	}*/

	graph.add_node(with_value: new_agent)
}

for i in 0...3*n {
	var fst = Int(Random.get_next()%101)
	var snd = Int(Random.get_next()%101)
	graph.add_edge(from: fst, to: snd, weight: Float(Random.get_next_normal(mu: 1.0)))
}

for i in 0..<n {
	var node = graph.find(hash: i)
	node?.value.update_connectedness(node: node!)
}

var crime_counts: [Int] = []
for d in 0..<3650 {
	var crime_count = 0
	for i in 0..<n {
		var agent = graph.find(hash: i)?.value
		if agent?.check_crime() != 0 {
			//print("-> Crime on day \(d) by agent \(i)")
			agent?.execute_crime(type: 1, on: graph.find(hash: Random.get_next()%n)!.value)
			crime_count += 1
		}
	}
	crime_counts += [crime_count]
}

//print(crime_counts)

try NSString(string: String(describing: crime_counts)).write(toFile: "out.txt", atomically: false, encoding: 2)

