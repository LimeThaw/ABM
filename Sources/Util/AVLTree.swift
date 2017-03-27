//
//  AVLTree.swift
//  ABM
//
//  Created by Tierry Hörmann on 21.03.17.
//
//

public struct AVLTree<T: Comparable> {
    let root: AVLTreeNode<T>
    
    public init(){
        root = .Leaf
    }
    
    init(_ root: AVLTreeNode<T>){
        self.root = root
    }
    
    public func value() -> T? {
        return root.value()
    }
    
    public func contains(_ val: T) -> Bool {
        return root.contains(val)
    }
    
    public func find(_ val: T) -> T? {
        return root.find(val)
    }
    
    public func smallest() -> T? {
        return root.smallest()
    }
    
    public func largest() -> T? {
        return root.largest()
    }
    
    public func removeSmallest() -> (T?, AVLTree<T>) {
        let tmp = root.removeSmallest()
        return (tmp.0, AVLTree(tmp.1))
    }
    
    public func removeLargest() -> (T?, AVLTree<T>) {
        let tmp = root.removeLargest()
        return (tmp.0, AVLTree(tmp.1))
    }
    
    public func height() -> Int {
        return root.height()
    }
    
    public func insert(_ val: T) -> AVLTree<T> {
        return AVLTree<T>(root.insert(val))
    }
    
    public func delete(_ val: T) -> AVLTree<T> {
        return AVLTree<T>(root.delete(val))
    }
}

enum AVLTreeNode<T: Comparable> {
    case Leaf
    indirect case Node(T, AVLTreeNode<T>, AVLTreeNode<T>, Int)
    
    init(){
        self = .Leaf
    }
    
    func value() -> T? {
        switch self {
        case .Leaf:
            return nil
        case let .Node(val, _, _, _):
            return val
        }
    }
    
    func contains(_ val: T) -> Bool {
        return find(val) != nil
    }
    
    func find(_ val: T) -> T? {
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
    
    func smallest() -> T? {
        return removeSmallest().0
    }
    
    func largest() -> T? {
        return removeLargest().0
    }
    
    func removeSmallest() -> (T?, AVLTreeNode<T>) {
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
    
    func removeLargest() -> (T?, AVLTreeNode<T>) {
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
    
    private func balance() -> BalanceType {
        return BalanceType(balance())
    }
    
    private func balance() -> Int {
        switch self {
        case let .Node(_, l, r, _):
            return r.height()-l.height()
        default:
            return 0
        }
    }
    
    private func rotateRight() -> AVLTreeNode<T> {
        switch self {
        case .Leaf:
            return self
        case let .Node(v, l, r, _):
            let newL = l.balance() > 0 ? l.rotateLeft() : l
            switch newL {
            case let .Node(vl, ll, rl, _):
                let nuR = AVLTreeNode<T>.Node(v, rl, r, rl.height() + 1)
                return .Node(vl, ll, nuR, max(ll.height(), nuR.height()) + 1)
            default:
                assert(false)
            }
        }
    }
    
    private func rotateLeft() -> AVLTreeNode<T> {
        switch self {
        case let .Node(v, l, r, _):
            let newR = r.balance() < 0 ? r.rotateRight() : r
            switch newR {
            case let .Node(vr, lr, rr, _):
                let nuL = AVLTreeNode<T>.Node(v, l, lr, lr.height() + 1)
                return .Node(vr, nuL, rr, max(nuL.height(), rr.height()) + 1)
            default:
                assert(false)
            }
        default:
            return self
        }
    }
    
    private func balance() -> AVLTreeNode<T> {
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
    
    func insert(_ val: T) -> AVLTreeNode<T> {
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
    
    func delete(_ val: T) -> AVLTreeNode<T> {
        switch self {
        case .Leaf:
            return self
        case let .Node(v, l, r, _):
            if v == val {
                let delL = l.removeLargest()
                let delR = r.removeSmallest()
                let res1 = AVLTreeNode<T>.Node(v, l, delR.1, max(l.height(), delR.1.height()))
                let res2 = AVLTreeNode<T>.Node(v, delL.1, r, max(delL.1.height(), r.height()))
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

extension AVLTreeNode {
    func toList() -> [T] {
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


public extension AVLTree {
    public func toList() -> [T] {
        return root.toList()
    }
}

private enum BalanceType {
    case Left, Center, Right
    init(_ arg: Int) {
        self = arg < -1 ? .Left : arg > 1 ? .Right : .Center
    }
}
