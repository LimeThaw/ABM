//
//  AVLTree.swift
//  ABM
//
//  Created by Tierry Hörmann on 21.03.17.
//
//

// Adds an index to an object for sortability and searchability
struct IndexedObject<T: Hashable>: Comparable {
	let index: Int
	let object: T?

	init(from object: T) {
		self.object = object
		index = object.hashValue
	}

	init(value: Int) {
		index = value
		object = nil
	}

	static func ==(_ one: IndexedObject<T>, _ two: IndexedObject<T>) -> Bool {
		return one.index == two.index
	}

	static func <(_ one: IndexedObject<T>, _ two: IndexedObject<T>) -> Bool {
		return one.index < two.index
	}
}

enum AVLTree<T: Comparable> {
    case Leaf
    indirect case Node(T, AVLTree<T>, AVLTree<T>, Int)

    init(){
        self = .Leaf
    }

    func rootValue() -> T? {
        switch self {
        case .Leaf:
            return nil
        case let .Node(val, _, _, _):
            return val
        }
    }

    func contains(val: T) -> Bool {
        switch self {
        case .Leaf:
            return false
        case let .Node(cur, t1, t2, _):
            return cur == val || t1.contains(val: val) || t2.contains(val: val)
        }
    }

	func search(_ val: T) -> T? {
		switch self {
		case let .Node(v, l, r, _):
			if v == val {
				return v
			} else if val < v {
				return l.search(val)
			} else {
				return r.search(val)
			}
		default:
			return nil
		}
	}

    func smallest() -> T? {
        return removeSmallest().0
    }

    func largest() -> T? {
        return removeLargest().0
    }

    func removeSmallest() -> (T?, AVLTree<T>) {
        switch self {
        case let .Node(v, l, r, h):
            let next = l.removeSmallest()
            let retTree = next.0 == nil ? r : .Node(v, next.1, r, max(r.height(), h-1))
            let retVal = next.0 == nil ? v : next.0
            return (retVal, retTree.balance())
        default:
            return (nil, .Leaf)
        }
    }

    func removeLargest() -> (T?, AVLTree<T>) {
        switch self {
        case let .Node(v, l, r, h):
            let next = r.removeLargest()
            let retTree = next.0 == nil ? l : .Node(v, l, next.1, max(l.height(), h-1))
            let retVal = next.0 == nil ? v : next.0
            return (retVal, retTree.balance())
        default:
            return (nil, .Leaf)
        }
    }

    func height() -> Int {
        switch self {
        case .Leaf:
            return 0
        case let .Node(_, _, _, b):
            return b
        }
    }

    private func balanced() -> BalanceType {
        switch self {
        case .Leaf:
            return .Center
        case let .Node(_, l, r, _):
            return BalanceType(r.height()-l.height())
        }
    }

    private func balance() -> AVLTree<T> {
        func rotateRight() -> AVLTree<T> {
            switch self {
            case .Leaf:
                return self
            case let .Node(v, l, r, _):
                switch l {
                case let .Node(vl, ll, rl, _):
                    let nuR = AVLTree<T>.Node(v, rl, r, max(rl.height(), r.height()) + 1)
                    return .Node(vl, ll, nuR, max(ll.height(), nuR.height()) + 1)
                default:
                    assert(false)
                }
            }
        }

        func rotateLeft() -> AVLTree<T> {
            switch self {
            case let .Node(v, l, r, _):
                switch r {
                case let .Node(vr, lr, rr, _):
                    let nuL = AVLTree<T>.Node(v, l, lr, max(l.height(), lr.height()) + 1)
                    return .Node(vr, nuL, rr, max(nuL.height(), rr.height()) + 1)
                default:
                    assert(false)
                }
            default:
                return self
            }
        }

        switch self {
        case .Leaf:
            return self
        case let .Node(_, t1, t2, _):
            switch BalanceType(t2.height() - t1.height()) {
            case .Center:
                return self
            case .Left:
                return rotateRight()
            case .Right:
                return rotateLeft()
            }
        }
    }

    func insert(val: T) -> AVLTree<T> {
        switch self {
        case .Leaf:
            return .Node(val, .Leaf, .Leaf, 1)
        case let .Node(v, l, r, _):
            let n = (v > val) ? AVLTree<T>.Node(v, l.insert(val: val), r, max(l.height() + 1, r.height())) : v < val ? AVLTree<T>.Node(v, l, r.insert(val:val), max(l.height(), r.height()+1)) : self
            return n.balance()
        }
    }

    func delete(val: T) -> AVLTree<T> {
        switch self {
        case .Leaf:
            return self
        case let .Node(v, l, r, _):
            if v == val {
                let delL = l.removeLargest()
                let delR = r.removeSmallest()
                let res1 = AVLTree<T>.Node(v, l, delR.1, max(l.height(), delR.1.height()))
                let res2 = AVLTree<T>.Node(v, delL.1, r, max(delL.1.height(), r.height()))
                let tmp = delL.0 == nil ? delR.0 == nil ? .Leaf : res1 : res2
                return tmp.balance()
            } else if val > v {
                return r.delete(val: val)
            } else {
                return l.delete(val: val)
            }
        }
    }
}

extension AVLTree {
    func toList() -> [T] {
        switch self {
        case let .Node(v,l,r,_):
            let left = l.toList()
            let right = r.toList()
            return  [v] + left + right
        default:
            return []
        }
    }
}

private enum BalanceType {
    case Left, Center, Right
    init(_ arg: Int) {
        self = arg < -1 ? .Left : arg > 1 ? .Right : .Center
    }
}