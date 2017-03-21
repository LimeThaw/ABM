// Enum used to indicate the direction of a rotation in the tree
enum Direction {
	case left
	case right
}

// A single, generic node in an AVL tree.
class AVLNode<T: Comparable> {
	var value: T
	var balance: Int = 0

	var parent: AVLNode<T>? = nil
	var left_child: AVLNode<T>? = nil
	var right_child: AVLNode<T>? = nil

	// Constructor
	init(value: T) {
		self.value = value
	}

	// Inserts a value in the subtree of which the node is the root.
	// If the length of the subtree increased, the function returns true, otherwise false.
	func insert(value new_value: T) -> Bool {

		let target_child = new_value <= self.value ? left_child : right_child
		if target_child == nil {

			// Insert new child node directly inder this one
			if target_child === left_child {
				left_child = AVLNode<T>(value: new_value)
				left_child!.parent = self
			} else {
				right_child = AVLNode<T>(value: new_value)
				right_child!.parent = self
			}

			// Update balance and return as appropriate
			balance = target_child === left_child ? balance - 1 : balance + 1;
			return balance == 0 ? false : true

		} else {

			// Instruct the next node to insert the value and update balance if needed
			if target_child!.insert(value: new_value) {
				balance = target_child === left_child ? balance - 1 : balance + 1;
			}

			// Rotate if needed
			if balance < -1 {
				if left_child!.balance == -1 {
					rotate(Direction.right)
				} else { // left_child.balance == 1 (if 0 there would be no upin)
					double_rotate(Direction.right)
				}
			} else if balance > 1 {
				if right_child!.balance == 1 {
					rotate(Direction.left)
				} else { // Same reasoning as 1st case
					double_rotate(Direction.left)
				}
			} else if balance == 0 {
				return true // Subtree grew higher
			}

			return false // No need to worry
		}

	}

	// Rotates the node according to AVL procedures. Used to keep the AVL condition true.
	private func rotate(_ side: Direction) {
		// The child we want to rotate above us
		let child = side == Direction.right ? left_child : right_child
		if child == nil { // Why are we rotating?!
			print("!Warning: Invalid single rotation\n")
			return
		}

		// The grandchild we want to adopt from our child
		let grand_child = side == Direction.right ? child!.right_child : child!.left_child

		// Append child to parent
		if parent != nil {
			if parent!.left_child === self {
				parent!.left_child = child
			} else {
				parent!.right_child = child
			}
		}
		child!.parent = parent

		// Append self to child
		if side == Direction.right {
			child!.right_child = self
		} else {
			child!.right_child = self
		}
		parent = child

		// Append grandchild to self
		if side == Direction.right {
			left_child = grand_child
		} else {
			right_child = grand_child
		}
		if grand_child != nil {
			grand_child!.parent = self
		}
	}

	private func double_rotate(_ side: Direction) {
		// The child to stay in place
		let child = side == Direction.right ? left_child : right_child
		if child == nil { // Why are we rotating?!
			print("!Warning: Invalid double rotation\n")
			return
		}

		// The grandchild to rise to the top
		let grand_child = side == Direction.right ? child!.right_child : child!.left_child
		if grand_child == nil { // Wrong rotation?
			print("!Warning: Invalid double rotation - Maybe try single roation instead?\n")
			return
		}

		// Take care of the grandchild's children
		if(side == Direction.right) {
			child!.right_child = grand_child!.left_child
			if child!.right_child != nil {
				child!.right_child!.parent = child
			}
			left_child = grand_child!.right_child
			if left_child != nil {
				left_child!.parent = self
			}
		} else {
			child!.left_child = grand_child!.right_child
			if child!.left_child != nil {
				child!.left_child!.parent = child
			}
			right_child = grand_child!.left_child
			if right_child != nil {
				right_child!.parent = self
			}
		}

		// Append grandchild to parent
		grand_child!.parent = parent
		if parent != nil {
			if parent!.left_child === self {
				parent!.left_child = grand_child
			} else {
				parent!.right_child = grand_child
			}
		}

		// Append new children to grandchild
		if side == Direction.right {
			grand_child!.left_child = child
			child!.parent = grand_child
			grand_child!.right_child = self
			parent = grand_child
		} else {
			grand_child!.right_child = child
			child!.parent = grand_child
			grand_child!.left_child = self
			parent = grand_child
		}
	}
}

// A generic AVL-Tree.
struct AVLTree<T: Comparable> {
	private var parent_node: AVLNode<T>?

	mutating func insert(value val: T) {
		if parent_node == nil {
			parent_node = AVLNode<T>(value: val)
		} else {
			_ = parent_node!.insert(value: val)
		}
	}
}