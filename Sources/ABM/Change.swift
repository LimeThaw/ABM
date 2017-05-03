import Util

enum ChangeType {
	case delete
	case function( (GraphNode<Agent>) -> Void )
}

struct Change {

	let target: GraphNode<Agent>
	let type: ChangeType

	init(toTarget other: GraphNode<Agent>, of givenType: ChangeType) {
		target = other
		type = givenType
	}

	public func apply(within graph: Graph<Agent>) {
		switch type {
			case .delete:
				graph.removeNode(node: target)

			case .function(let fun):
				fun(target)
		}
	}

}