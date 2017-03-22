print("Hello, world!")

Random.set_seed(to: 12345)

var graph = Graph<Agent>()
for i in 0...100 {
	graph.add_node(with_value: Agent())
}

for i in 0...200 {
	var fst = Int(Random.get_next()%101)
	var snd = Int(Random.get_next()%101)
	graph.add_edge(from: fst, to: snd, weight: 0.5)
}

for i in 1...25 {
	print(Random.get_next()%101)
}