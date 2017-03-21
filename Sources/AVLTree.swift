//
//  AVLTreeE.swift
//  ABM
//
//  Created by Tierry Hörmann on 21.03.17.
//
//

enum AVLTreeE<T: Comparable> {
    case Leaf
    indirect case Node(T, AVLTreeE<T>, AVLTreeE<T>)
    
    func contains(val: T) -> Bool {
        switch self {
        case .Leaf:
            return false
        case let .Node(cur, t1, t2):
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
        case let .Node(v, l, r):
            let next = l.removeSmallest()
            return next.0 == nil ? (v, r) : (next.0, .Node(v, next.1, r))
        default:
            return (nil, .Leaf)
        }
    }
    
    func removeLargest() -> (T?, AVLTreeE<T>) {
        switch self {
        case let .Node(v, l, r):
            let next = r.removeLargest()
            return next.0 == nil ? (v, l) : (next.0, .Node(v, l, next.1))
        default:
            return (nil, .Leaf)
        }
    }
    
    func height() -> Int {
        switch self {
        case .Leaf:
            return 0
        case let .Node(_, t1, t2):
            return 1 + max(t1.height(), t2.height())
        }
    }
    
    private func balanced() -> BalanceType {
        switch self {
        case .Leaf:
            return .Center
        case let .Node(_, t1, t2):
            return BalanceType(arg: t1.height() - t2.height())
        }
    }
    
    func balance() -> AVLTreeE<T> {
        switch self {
        case .Leaf:
            return self
        case let .Node(cur, t1, t2):
            switch self.balanced() {
            case .Center:
                return self
            case .Left:
                switch t1.balance() {
                case let .Node(v, l, r):
                    return .Node(v, l, .Node(cur, r, t2.balance()))
                default:
                    assert(false)
                }
            case .Right:
                switch t2.balance() {
                case let .Node(v, l, r):
                    return .Node(v, .Node(cur, t1.balance(), l), r)
                default:
                    assert(false)
                }
            }
        }
    }
    
    func insert(val: T) -> AVLTreeE<T> {
        switch self {
        case .Leaf:
            return .Node(val, .Leaf, .Leaf)
        case let .Node(v, l, r):
            let n = (v > val) ? AVLTreeE<T>.Node(v, l.insert(val: val), r) : AVLTreeE<T>.Node(v, l, r.insert(val:val))
            return n.balance()
        }
    }
    
    func delete(val: T) -> AVLTreeE<T> {
        switch self {
        case .Leaf:
            return self
        case let .Node(v, l, r):
            let delL = l.removeLargest()
            let delR = r.removeSmallest()
            let res1 = AVLTreeE<T>.Node(v, l, delR.1)
            let res2 = AVLTreeE<T>.Node(v, delL.1, r)
            let tmp = delL.0 == nil ? delR.0 == nil ? .Leaf : res1 : res2
            return tmp.balance()
        }
    }
    
    func toList() -> [T] {
        switch self {
        case let .Node(v,l,r):
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
    init(arg: Int) {
        self = arg > 1 ? .Left : arg < -1 ? .Right : .Center
    }
}
