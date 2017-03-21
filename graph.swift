// Generic node class. Simply stores a value of a chosen type.
class Node<Type> {
	var value: Type

	init(value: Type) {
		self.value = value
	}
}

// Generic edge class. Connects two nodes of the same type. The edge specifies the data type the nodes need to store.
// Additionally the edge stores a weight value of type Int.
class Edge<Type> {
	let fst_node: Node<Type>
	let snd_node: Node<Type>
	var weight: Int

	init(fst_node: Node<Type>, snd_node: Node<Type>, weight: Int) {
		self.fst_node = fst_node
		self.snd_node = snd_node
		self.weight = weight
	}
}

// Generic graph class. Contains a list of nodes and a list of edges connecting the nodes.
class Graph<Type> {
	private var nodes: [Node<Type>] = []
	private var edges: [Edge<Type>] = []

	// Adds a new node with the given value to the graph
	func add_node(new_node_value new_value: Type) {
		let new_node = Node(value: new_value)
		nodes.append(new_node)
	}
}
