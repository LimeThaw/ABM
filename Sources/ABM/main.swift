import Foundation

var graph = Graph<Agent>()
for i in 0...100 {
	var new_agent = Agent()
	new_agent.happiness = Float(rand.next_normal(mu: Double(new_agent.happiness), sig2: 0.5))
	/*if Random.get_next() % 100 <= 5 { // Person is unemployed
		new_agent.daily_income = 15
	}
	if Random.get_next() % 3 == 0 { // Person owns a firearm
		new_agent.owns_gun = true
	}*/

	graph.add_node(with_value: new_agent)
}

for i in 0...200 {
	var fst = Int(rand.next()%101)
	var snd = Int(rand.next()%101)
	graph.add_edge(from: fst, to: snd, weight: 0.5)
}

var crime_counts: [Int] = []
for d in 0..<3650 {
	var crime_count = 0
	for i in 0...100 {
        /* FIXME
		var agent = graph.find(hash: i)?.value
		if agent?.check_crime() != 0 {
			//print("-> Crime on day \(d) by agent \(i)")
			agent?.execute_crime(type: 1, on: graph.find(hash: rand.next()%101)!.value)
			crime_count += 1
		}
         */
	}
	crime_counts += [crime_count]
}

//print(crime_counts)

try NSString(string: String(describing: crime_counts)).write(toFile: "out.txt", atomically: false, encoding: 2)

