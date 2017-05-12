// Generic node class. Simply stores a value of a chosen type.
public class GraphNode<T: Hashable>: Hashable {
	public private(set) var value: T // The value assigned to a specific node
    public private(set) var edges: [Int:Edge<T>] // The connections to other nodes with a weight
	// Note: For undirected edges the other node should have an edge to this one with
	// 	     the same assigned weight

	public var hashValue: Int

	// Constructor
	init(value: T) {
		self.value = value
		edges = [:]
		hashValue = value.hashValue
	}

	// Add an edge to this node
	func add_edge(to other: GraphNode<T>, weight: Float = 0) {
		let edge = Edge(to: other, weight: weight)
		edges[edge.hashValue] = edge
	}

	// Removes the edge from this node to the given one if it exists
	func removeEdge(to other: GraphNode<T>) {
        edges.removeValue(forKey: other.hashValue)
	}

	// Conforming to Equatable for Hashable.
	public static func ==(_ one: GraphNode<T>, _ two: GraphNode<T>) -> Bool {
		return one.value == two.value
	}
}

// What kind of edge would the Sir prefer?
public enum EdgeKind {
	case DIRECTED
	case UNDIRECTED
}

// A simple connection to another node
public struct Edge<T: Hashable>: Hashable {
	public let next: GraphNode<T> // The other node of the edge
	public var weight: Float // The weight of the edge
	public let type: EdgeKind

	public var hashValue: Int { return next.value.hashValue }

	init(to other: GraphNode<T>, weight: Float, kind: EdgeKind = .UNDIRECTED) {
		next = other
		self.weight = weight
		self.type = kind
	}

	public static func ==(_ one: Edge<T>, _ two: Edge<T>) -> Bool {
		return one.hashValue == two.hashValue && one.weight == two.weight
	}
}

// Generic graph class. Contains a list of nodes and a list of edges connecting the nodes.
public class Graph<T: Hashable> {
    public private(set) var nodes: [Int:GraphNode<T>] = [:]

	public init() {}

	// Adds a new node with the given value to the graph
	public func addNode(withValue newValue: T) -> GraphNode<T> {
		let ret = GraphNode<T>(value: newValue)
        addNode(ret)
		return ret
	}

	// Inserts a node into the graph
	public func addNode(_ newNode: GraphNode<T>) {
        nodes[newNode.hashValue] = newNode
	}

	// Removes a node from the graph, and takes care of all undirected edges to/from it.
	// Directed edges to it are not deleted, unless there is an undirected edge in the opposite
	// direction.
	public func removeNode(node: GraphNode<T>) {
        assert(nodes[node.hashValue] != nil, "Should not remove node that is not contained in graph")
		for next in node.edges.values {
			if next.type == .UNDIRECTED {
				removeEdge(from: next.next.hashValue, to:node.hashValue)
			}
		}
		nodes[node.hashValue] = nil
	}

	public func removeNode(withValue value: T) {
		removeNode(node: GraphNode<T>(value: value))
	}

	// Find node with a payload
	public func find(node: T) -> GraphNode<T>? {
        return find(hash: node.hashValue)
	}

	// Find with the node's hash value
	public func find(hash: Int) -> GraphNode<T>? {
		return nodes[hash]
	}

	// Adds an edge with the specified weights between nodes with the specified keys.
	// Unless requested otherwise it will be an undirected/bidirectional edge
	public func addEdge(from first: Int, to second: Int, weight: Float, _ kind: EdgeKind = EdgeKind.UNDIRECTED) {
		let fst = nodes[first]
		let snd = nodes[second]
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

	public func removeEdge(from first: Int, to second: Int, _ kind: EdgeKind = EdgeKind.UNDIRECTED) {
		let fst = nodes[first]
		let snd = nodes[second]
		if fst == nil && snd == nil { print("a") }
		if fst == nil || snd == nil {
			print("!Warning: Tried to remove edge between non-existing nodes")
			return
		} else {
			fst!.removeEdge(to: snd!)
			if kind == EdgeKind.UNDIRECTED {
				snd!.removeEdge(to: fst!)
			}
		}
	}
}
