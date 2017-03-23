
//
//  AVLTreeE.swift
//  ABM
//
//  Created by Tierry Hörmann on 21.03.17.
//
//


enum AVLTreeE<T: Comparable> {
    case Leaf
    indirect case Node(T, AVLTreeE<T>, AVLTreeE<T>, Int)

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

    func smallest() -> T? {
        return removeSmallest().0
    }

    func largest() -> T? {
        return removeLargest().0
    }

    func removeSmallest() -> (T?, AVLTreeE<T>) {
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

    func removeLargest() -> (T?, AVLTreeE<T>) {
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

    private func balance() -> AVLTreeE<T> {
        func rotateRight() -> AVLTreeE<T> {
            switch self {
            case .Leaf:
                return self
            case let .Node(v, l, r, _):
                switch l {
                case let .Node(vl, ll, rl, _):
                    let nuR = AVLTreeE<T>.Node(v, rl, r, max(rl.height(), r.height()) + 1)
                    return .Node(vl, ll, nuR, max(ll.height(), nuR.height()) + 1)
                default:
                    assert(false)
                }
            }
        }

        func rotateLeft() -> AVLTreeE<T> {
            switch self {
            case let .Node(v, l, r, _):
                switch r {
                case let .Node(vr, lr, rr, _):
                    let nuL = AVLTreeE<T>.Node(v, l, lr, max(l.height(), lr.height()) + 1)
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

    func insert(val: T) -> AVLTreeE<T> {
        switch self {
        case .Leaf:
            return .Node(val, .Leaf, .Leaf, 1)
        case let .Node(v, l, r, _):
            let n = (v > val) ? AVLTreeE<T>.Node(v, l.insert(val: val), r, max(l.height() + 1, r.height())) : v < val ? AVLTreeE<T>.Node(v, l, r.insert(val:val), max(l.height(), r.height()+1)) : self
            return n.balance()
        }
    }

    func delete(val: T) -> AVLTreeE<T> {
        switch self {
        case .Leaf:
            return self
        case let .Node(v, l, r, _):
            if v == val {
                let delL = l.removeLargest()
                let delR = r.removeSmallest()
                let res1 = AVLTreeE<T>.Node(v, l, delR.1, max(l.height(), delR.1.height()))
                let res2 = AVLTreeE<T>.Node(v, delL.1, r, max(delL.1.height(), r.height()))
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

extension AVLTreeE {
    func toList() -> [T] {
        switch self {
        case let .Node(v,l,r,_):
            let left = l.toList()
            let right = r.toList()
            return  [v] + left + right
        default:
            return []
        }

        balance(node: parent)
      } else {
        // at root
        root = nil
      }
    } else {
      // Handle stem cases
      if let replacement = node.leftChild?.maximum() , replacement !== node {
        node.key = replacement.key
        node.payload = replacement.payload
        delete(node: replacement)
      } else if let replacement = node.rightChild?.minimum() , replacement !== node {
        node.key = replacement.key
        node.payload = replacement.payload
        delete(node: replacement)
      }
    }
  }
}


private enum BalanceType {
    case Left, Center, Right
    init(_ arg: Int) {
        self = arg < -1 ? .Left : arg > 1 ? .Right : .Center
    }
    return s
  }
}

extension AVLTree: CustomDebugStringConvertible {
  public var debugDescription: String {
    if let root = root {
      return root.debugDescription
    } else {
      return "[]"
    }
  }
}

extension TreeNode: CustomStringConvertible {
  public var description: String {
    var s = ""
    if let left = leftChild {
      s += "(\(left.description)) <- "
    }
    s += "\(key)"
    if let right = rightChild {
      s += " -> (\(right.description))"
    }
    return s
  }
}

extension AVLTree: CustomStringConvertible {
  public var description: String {
    if let root = root {
      return root.description
    } else {
      return "[]"
    }
  }
}