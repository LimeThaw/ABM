// Generic node class. Simply stores a value of a chosen type.
public class GraphNode<T: Hashable>: DynamicHashable {
    public private(set) var value: T // The value assigned to a specific node
    public private(set) var edges: [Int:Edge<T>] // The connections to other nodes with a weight
    // Note: For undirected edges the other node should have an edge to this one with
    // 	     the same assigned weight
    
    public let hashValue: Int
    public var dynamicHashValue: Int = 0
    
    // Constructor
    public init(value: T) {
        self.value = value
        edges = [:]
        hashValue = value.hashValue
    }
    
    // Add an edge to this node
    // If edge is already present it will add the weights
    func add_edge(to other: GraphNode<T>, weight: Double = 0) {
        if edges[other.hashValue] == nil {
            let edge = Edge(to: other, weight: weight)
            edges[edge.hashValue] = edge
        } else {
            edges[other.hashValue]!.weight += weight
        }
    }
    
    // Removes the edge from this node to the given one if it exists
    @discardableResult
    func removeEdge(to other: GraphNode<T>) -> Edge<T>? {
        return edges.removeValue(forKey: other.hashValue)
    }
    
    // Returns the weight of the edge from this node to the other or 0 if the edge doesn't exist
    public func getEdgeWeight(to other: GraphNode<T>) -> Double {
        if edges[other.hashValue] == nil {
            return 0.0
        } else {
            return edges[other.hashValue]!.weight
        }
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
    public var weight: Double // The weight of the edge
    public let type: EdgeKind
    
    public var hashValue: Int { return next.hashValue }
    
    init(to other: GraphNode<T>, weight: Double, kind: EdgeKind = .UNDIRECTED) {
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
    public var nodes: RAHT<GraphNode<T>>
    
    public init(seed: Int) {
        nodes = RAHT<GraphNode<T>>(seed: seed)
    }
    
    // Adds a new node with the given value to the graph
    @discardableResult
    public func addNode(withValue newValue: T) -> GraphNode<T> {
        let ret = GraphNode<T>(value: newValue)
        addNode(ret)
        return ret
    }
    
    // Inserts a node into the graph
    public func addNode(_ newNode: GraphNode<T>) {
        nodes.insert(newNode)
    }
    
    // Removes a node from the graph, and takes care of all undirected edges to/from it.
    // Directed edges to it are not deleted, unless there is an undirected edge in the opposite
    // direction.
    public func remove_node(node: GraphNode<T>) {
        //assert(nodes.has(staticHash: node.hashValue), "Should not remove node that is not contained in graph")
        if nodes.has(staticHash: node.hashValue) {
            for next in node.edges.values {
                if next.type == .UNDIRECTED {
                    remove_edge(from: next.next, to:node)
                }
            }
            nodes.remove(node)
        }
    }
    
    public func remove_node(withValue value: T) {
        remove_node(node: GraphNode<T>(value: value))
    }
    
    // Find node with a payload
    public func find(node: T) -> GraphNode<T>? {
        return find(hash: node.hashValue)
    }
    
    // Find with the node's hash value
    public func find(hash: Int) -> GraphNode<T>? {
        return nodes.get(staticHash: hash)
    }
    
    // Adds an edge with the specified weights between nodes with the specified keys.
    // Unless requested otherwise it will be an undirected/bidirectional edge
    public func add_edge(from first: GraphNode<T>, to second: GraphNode<T>, weight: Double, _ kind: EdgeKind = EdgeKind.UNDIRECTED) {
        first.add_edge(to: second, weight: weight)
        if kind == EdgeKind.UNDIRECTED {
            second.add_edge(to: first, weight: weight)
        }
    }
    
    @discardableResult
    public func remove_edge(from first: GraphNode<T>, to second: GraphNode<T>, _ kind: EdgeKind = EdgeKind.UNDIRECTED) -> Edge<T>? {
        let ret = first.removeEdge(to: second)
        if kind == EdgeKind.UNDIRECTED {
            second.removeEdge(to: first)
        }
        return ret
    }
    
    public func getRandomNode() -> GraphNode<T>? {
        return nodes.getRandom()
    }
}
