// Generic node class. Simply stores a value of a chosen type.
class Node<T: Hashable> {
	private(set) var value: T // The value assigned to a specific node
	private(set) var edges: AVLTree<Int, Edge<T>> // The connections to other nodes with a weight
	// Note: For undirected edges the other node should have an edge to this one with
	// 	     the same assigned weight

	// Constructor
	init(value: T) {
		self.value = value
		edges = AVLTree<Int, Edge<T>>()
	}

	// Add an edge to this node
	func add_edge(to other: Node<T>, weight: Float = 0) {
		let edge = Edge(to: other, weight: weight)
		edges.insert(key: other.value.hashValue, payload: edge)
	}
}

// A simple connection to another node
struct Edge<T: Hashable> {
	let next: Node<T> // The other node of the edge
	var weight: Float // The weight of the edge

	init(to other: Node<T>, weight: Float) {
		next = other
		self.weight = weight
	}
}

enum EdgeKind {
	case DIRECTED
	case UNDIRECTED
}

// Generic graph class. Contains a list of nodes and a list of edges connecting the nodes.
class Graph<T: Hashable> {
	private var nodes: AVLTree<Int, Node<T>> = AVLTree<Int, Node<T>>()

	// Adds a new node with the given value to the graph
	func add_node(with_value new_value: T) {
		let new_node = Node(value: new_value)
		nodes.insert(key: new_node.value.hashValue, payload: new_node)
	}

	func add_node(_ new_node: Node<T>) {
		nodes.insert(key: new_node.value.hashValue, payload: new_node)
	}

	// Find node with a payload
	func find(node: T) -> Node<T>? {
		return nodes[node.hashValue]
	}

	// Find with the node's hash value
	func find(hash: Int) -> Node<T>? {
		return nodes[hash]
	}

	// Adds an edge with the specified weights between nodes with the specified keys.
	// Unless requested otherwise it will be an undirected/bidirectional edge
	func add_edge(from first: Int, to second: Int, weight: Float, _ kind: EdgeKind = EdgeKind.UNDIRECTED) {
		let fst = nodes.search(input: first)
		let snd = nodes.search(input:second)
		if fst == nil || snd == nil {
			print("!Warning: Tried to insert edge between non-existing nodes")
			return
		} else {
			fst!.add_edge(to: snd!, weight: weight)
			if kind == EdgeKind.UNDIRECTED {
				snd!.add_edge(to: fst!, weight: weight)
			}
		}
	}
}
