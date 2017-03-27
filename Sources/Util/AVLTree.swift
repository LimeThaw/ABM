//
//  AVLTree.swift
//  ABM
//
//  Created by Tierry Hörmann on 21.03.17.
//
//


public enum AVLTree<T: Comparable> {
    case Leaf
    indirect case Node(T, AVLTree<T>, AVLTree<T>, Int)
    
    public init(){
        self = .Leaf
    }
    
    public func rootValue() -> T? {
        switch self {
        case .Leaf:
            return nil
        case let .Node(val, _, _, _):
            return val
        }
    }
    
    public func contains(_ val: T) -> Bool {
        return find(val) != nil
    }
    
    public func find(_ val: T) -> T? {
        switch self {
        case let .Node(v, l, r, _):
            if v == val {
                return v
            } else if val < v {
                return l.find(val)
            } else {
                return r.find(val)
            }
        default:
            return nil
        }
    }
    
    public func smallest() -> T? {
        return removeSmallest().0
    }
    
    public func largest() -> T? {
        return removeLargest().0
    }
    
    public func removeSmallest() -> (T?, AVLTree<T>) {
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
    
    public func removeLargest() -> (T?, AVLTree<T>) {
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
    
    public func height() -> Int {
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
    
    public func insert(_ val: T) -> AVLTree<T> {
        switch self {
        case .Leaf:
            return .Node(val, .Leaf, .Leaf, 1)
        case let .Node(v, l, r, _):
            let newL = val < v ? l.insert(val) : l
            let newR = val > v ? r.insert(val) : r
            let n = v == val ? self : .Node(v, newL, newR, max(newL.height(), newR.height()) + 1)
            return n.balance()
        }
    }
    
    public func delete(_ val: T) -> AVLTree<T> {
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
                return r.delete(val)
            } else {
                return l.delete(val)
            }
        }
    }
}

public extension AVLTree {
    public func toList() -> [T] {
        switch self {
        case let .Node(v,l,r,_):
            let left = l.toList()
            let right = r.toList()
            return left + [v] + right
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
