// Generic node class. Simply stores a value of a chosen type.
class Node<T: Hashable>: Hashable {
	private(set) var value: T // The value assigned to a specific node
	private(set) var edges: AVLTree<IndexedObject<Edge<T>>> // The connections to other nodes with a weight
	// Note: For undirected edges the other node should have an edge to this one with
	// 	     the same assigned weight

	var hashValue: Int

	// Constructor
	init(value: T) {
		self.value = value
		edges = AVLTree<IndexedObject<Edge<T>>>()
		hashValue = value.hashValue
	}

	// Add an edge to this node
	func add_edge(to other: Node<T>, weight: Float = 0) {
		let edge = Edge(to: other, weight: weight)
		edges = edges.insert(val: IndexedObject<Edge<T>>(from: edge))
	}

	static func ==(_ one: Node<T>, _ two: Node<T>) -> Bool {
		return one.value == two.value
	}
}

// A simple connection to another node
struct Edge<T: Hashable>: Hashable {
	let next: Node<T> // The other node of the edge
	var weight: Float // The weight of the edge

	var hashValue: Int { return next.value.hashValue }

	init(to other: Node<T>, weight: Float) {
		next = other
		self.weight = weight
	}

	static func ==(_ one: Edge<T>, _ two: Edge<T>) -> Bool {
		return one.hashValue == two.hashValue && one.weight == two.weight
	}
}

enum EdgeKind {
	case DIRECTED
	case UNDIRECTED
}

// Generic graph class. Contains a list of nodes and a list of edges connecting the nodes.
class Graph<T: Hashable> {
	private var nodes: AVLTree<IndexedObject<Node<T>>> = AVLTree<IndexedObject<Node<T>>>()

	// Adds a new node with the given value to the graph
	func addNode(withValue newValue: T) {
		let newNode = IndexedObject<Node<T>>(from: Node(value: newValue))
		nodes = nodes.insert(val: newNode)
	}

	func addNode(_ newNode: Node<T>) {
		nodes = nodes.insert(val: IndexedObject<Node<T>>(from: newNode))
	}

	// Find node with a payload
	func find(node: T) -> Node<T>? {
		return nodes.search(IndexedObject<Node<T>>(value: node.hashValue))?.object
	}

	// Find with the node's hash value
	func find(hash: Int) -> Node<T>? {
		return nodes.search(IndexedObject<Node<T>>(value: hash))?.object
	}

	// Adds an edge with the specified weights between nodes with the specified keys.
	// Unless requested otherwise it will be an undirected/bidirectional edge
	func addEdge(from first: Int, to second: Int, weight: Float, _ kind: EdgeKind = EdgeKind.UNDIRECTED) {
		let fst = nodes.search(IndexedObject<Node<T>>(value: first))?.object
		let snd = nodes.search(IndexedObject<Node<T>>(value: second))?.object
		if fst === nil || snd === nil {
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
