// Generic node class. Simply stores a value of a chosen type.
public class Node<T: Hashable>: Hashable {
	public private(set) var value: T // The value assigned to a specific node
	private(set) var edges: AVLTree<IndexedObject<Edge<T>>> // The connections to other nodes with a weight
	// Note: For undirected edges the other node should have an edge to this one with
	// 	     the same assigned weight

	public var hashValue: Int

	// Constructor
	init(value: T) {
		self.value = value
		edges = AVLTree<IndexedObject<Edge<T>>>()
		hashValue = value.hashValue
	}

	// Add an edge to this node
	func add_edge(to other: Node<T>, weight: Float = 0) {
		let edge = Edge(to: other, weight: weight)
		edges = edges.insert(IndexedObject<Edge<T>>(from: edge))
	}

	// Removes the edge from this node to the given one if it exists
	func removeEdge(to other: Node<T>) {
		let edge = edges.find(IndexedObject<Edge<T>>(value: other.hashValue))
		if edge != nil {
			edges = edges.delete(edge!)
		}
	}

	public func edgeList() -> [Edge<T>] {
		return edges.toList().map({$0.object!})
	}

	// Conforming to Equatable for Hashable.
	public static func ==(_ one: Node<T>, _ two: Node<T>) -> Bool {
		return one.value == two.value
	}
}

// A simple connection to another node
public struct Edge<T: Hashable>: Hashable {
	let next: Node<T> // The other node of the edge
	public var weight: Float // The weight of the edge

	public var hashValue: Int { return next.value.hashValue }

	init(to other: Node<T>, weight: Float) {
		next = other
		self.weight = weight
	}

	public static func ==(_ one: Edge<T>, _ two: Edge<T>) -> Bool {
		return one.hashValue == two.hashValue && one.weight == two.weight
	}
}

// What kind of edge would the Sir prefer?
public enum EdgeKind {
	case DIRECTED
	case UNDIRECTED
}

// Generic graph class. Contains a list of nodes and a list of edges connecting the nodes.
public class Graph<T: Hashable> {
	private var nodes: AVLTree<IndexedObject<Node<T>>> = AVLTree<IndexedObject<Node<T>>>()

	public var nodeCount: Int { return nodes.toList().count }
    public var nodeList: [Node<T>] { return nodes.toList().map({$0.object}) }

	public init() {}

	// Adds a new node with the given value to the graph
	public func addNode(withValue newValue: T) {
		let newNode = IndexedObject<Node<T>>(from: Node(value: newValue))
		addNode(newNode)
	}

	// Inserts a node into the graph
	public func addNode(_ newNode: Node<T>) {
		nodes = nodes.insert(IndexedObject<Node<T>>(from: newNode))
	}

	// Removes a node from the graph, and takes care of all undirected edges to/from it.
	// Directed edges to it are not deleted, unless there is an undirected edge in the opposite
	// direction.
	public func removeNode(node: Node<T>) {
		let ourNode = find(node: node.value)
		if  ourNode == nil {
			assert(false, "!Warning: Tried to remove node which wasn't in the graph")
			return
		}

		for edge in ourNode!.edges.toList() {
			edge.object?.next.removeEdge(to: ourNode!)
		}

		nodes = nodes.delete(IndexedObject<Node<T>>(value: node.hashValue))
	}

	public func removeNode(withValue value: T) {
		removeNode(node: Node<T>(value: value))
	}

	// Find node with a payload
	public func find(node: T) -> Node<T>? {
		return find(node.hashValue)
	}

	// Find with the node's hash value
	public func find(hash: Int) -> Node<T>? {
		return nodes.find(IndexedObject<Node<T>>(value: hash))?.object
	}

	// Adds an edge with the specified weights between nodes with the specified keys.
	// Unless requested otherwise it will be an undirected/bidirectional edge
	public func addEdge(from first: Int, to second: Int, weight: Float, _ kind: EdgeKind = EdgeKind.UNDIRECTED) {
		let fst = nodes.find(IndexedObject<Node<T>>(value: first))?.object
		let snd = nodes.find(IndexedObject<Node<T>>(value: second))?.object
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
