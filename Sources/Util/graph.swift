// Generic node class. Simply stores a value of a chosen type.
public class Node<T: Hashable>: Comparable {
    public let id: Int
	private(set) var value: T // The value assigned to a specific node
	private(set) var edges: AVLTree<Edge<T>> // The connections to other nodes with a weight
	// Note: For undirected edges the other node should have an edge to this one with
	// 	     the same assigned weight

	// Constructor
	public init(value: T) {
		self.value = value
		edges = AVLTree<Edge<T>>()
        id = counter.next()!
	}

	// Add an edge to this node
	public func add_edge(to other: Node<T>, weight: Float = 0) {
		let edge = Edge(to: other, weight: weight)
		edges = edges.insert(edge)
	}
    public static func ==(lhs: Node<T>, rhs: Node<T>) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func <(lhs: Node<T>, rhs: Node<T>) -> Bool {
        return lhs.id < rhs.id
    }
}

// A simple connection to another node
public struct Edge<T: Hashable>: Comparable {
    public let id: Int
	public let next: Node<T> // The other node of the edge
	public var weight: Float // The weight of the edge

	public init(to other: Node<T>, weight: Float) {
		next = other
		self.weight = weight
        id = counter.next()!
	}
    
    public static func ==(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func <(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
        return lhs.id < rhs.id
    }
}

public enum EdgeKind {
	case DIRECTED
	case UNDIRECTED
}

// Generic graph class. Contains a list of nodes and a list of edges connecting the nodes.
public class Graph<T: Hashable> {
	private var nodes: AVLTree<Node<T>> = AVLTree<Node<T>>()

	// Adds a new node with the given value to the graph
	public func add_node(with_value new_value: T) {
		let new_node = Node(value: new_value)
		nodes = nodes.insert(new_node)
	}

	public func add_node(_ new_node: Node<T>) {
		nodes = nodes.insert(new_node)
	}

    /*
	// Find node with a payload
	func find(node: T) -> Node<T>? {
		return nodes[node.hashValue]
	}

	// Find with the node's hash value
	func find(hash: Int) -> Node<T>? {
		return nodes[hash]
	}
    */

	// Adds an edge with the specified weights between nodes with the specified keys.
	// Unless requested otherwise it will be an undirected/bidirectional edge
	public func add_edge(from first: Int, to second: Int, weight: Float, _ kind: EdgeKind = EdgeKind.UNDIRECTED) {
        //TODO: correct this
        /*
		let fst = nodes.search(first)
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
        */
	}
}
