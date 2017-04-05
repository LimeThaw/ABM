//
//  AVLTree.swift
//  ABM
//
//  Created by Tierry Hörmann on 21.03.17.
//
//
import Foundation

/// Adds an index to an object for sortability and searchability
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

    private init(_ val: T, _ l: AVLTreeNode<T>, _ r: AVLTreeNode<T>){
        self = .Node(val, l, r, max(l.height(), r.height())+1)
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
        case let .Node(v, l, r, _):
            let next = l.removeSmallest()
            let retTree = {next.0 == nil ? r : AVLTreeNode<T>(v, next.1, r)}
            let retVal = {next.0 == nil ? v : next.0}
            return (retVal(), retTree().balance())
        default:
            return (nil, .Leaf)
        }
    }

    func removeLargest() -> (T?, AVLTreeNode<T>) {
        switch self {
        case let .Node(v, l, r, _):
            let next = r.removeLargest()
            let retTree = next.0 == nil ? l : AVLTreeNode<T>(v, l, next.1)
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
                let nuR = AVLTreeNode<T>(v, rl, r)
                return AVLTreeNode<T>(vl, ll, nuR)
            default:
                assert(false)
                return self
            }
        }
    }

    private func rotateLeft() -> AVLTreeNode<T> {
        switch self {
        case let .Node(v, l, r, _):
            let newR = r.balance() < 0 ? r.rotateRight() : r
            switch newR {
            case let .Node(vr, lr, rr, _):
                let nuL = AVLTreeNode<T>(v, l, lr)
                return AVLTreeNode<T>(vr, nuL, rr)
            default:
                assert(false)
                return self
            }
        default:
            return self
        }
    }

    private func balance() -> AVLTreeNode<T> {
        switch self {
        case .Leaf:
            return self
        case .Node:
            switch balance() as BalanceType {
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
            let n = v == val ? self : AVLTreeNode<T>(v, newL, newR)
            return n.balance()
        }
    }

    func delete(_ val: T) -> AVLTreeNode<T> {
        switch self {
        case .Leaf:
            return self
        case let .Node(v, l, r, _):
            if v == val {
                let lh = l.height()
                let rh = r.height()
                if lh == 0 && rh == 0 {
                    return .Leaf
                }
                if lh > rh {
                    let delL = l.removeLargest()
                    return AVLTreeNode<T>(delL.0!, delL.1, r).balance()
                } else {
                    let delR = r.removeSmallest()
                    return AVLTreeNode<T>(delR.0!, l, delR.1).balance()
                }
            } else if val > v {
                return AVLTreeNode<T>(v, l, r.delete(val))
            } else {
                return AVLTreeNode<T>(v, l.delete(val), r)
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
    
    func printTree() {
        var help: [[T?]] = [] // an array that hold the entries in the correct order for every level
        var levels = self.height()
        for _ in 0..<self.height() {
            help.append([])
        }
        
        func insertIntoHelp(tree: AVLTreeNode<T>, level: Int) {
            switch tree {
            case let .Node(v, l, r, _):
                var levelArray = help[level]
                levelArray.append(v)
                help[level] = levelArray
                insertIntoHelp(tree: l, level: level+1)
                insertIntoHelp(tree: r, level: level+1)
            default:
                var inserts = 1
                var curLevel = level
                while curLevel < levels { // level with only leafs won't be printed
                    var levelArray = help[curLevel]
                    for _ in 0..<inserts {
                        levelArray.append(nil)
                    }
                    help[curLevel] = levelArray
                    curLevel += 1
                    inserts *= 2
                }
            }
        }
        
        insertIntoHelp(tree: self, level: 0)
        var strHelp: [[String]] = [] // holds the string representations for every entry in the level
        var longestString = 0
        for i in help {
            var cur: [String] = []
            for j in i {
                if j == nil {
                    cur.append("")
                    if longestString < 6 {
                        longestString = 6
                    }
                } else {
                    let str = String(describing: j!)
                    if str.characters.count > longestString {
                        longestString = str.characters.count
                    }
                    cur.append(str)
                }
            }
            strHelp.append(cur)
        }
        
        longestString += 1 // every item is printed with at least one leading space
        // center the strings
        for i in 0..<strHelp.count {
            for j in 0..<strHelp[i].count {
                var cur = strHelp[i][j]
                let padding = (longestString - cur.characters.count) / 2
                var pad = ""
                for _ in 0..<padding{
                    pad += " "
                }
                cur = (longestString - cur.characters.count) % 2 == 0 ? pad + cur + pad : " " + pad + cur + pad
                strHelp[i][j] = cur
            }
        }
        
        // create the lines
        let width = longestString*2^^(levels-1)
        var lines: [String] = [] // the lines that are printed to the console
        var firstLine = true
        for i in 0..<levels {
            var cur = ""
            // whitespaces
            let boxSize = width / 2^^i
            var paddingStart = ""
            for _ in 0 ..< (boxSize - longestString) / 2 {
                paddingStart += " "
            }
            let paddingEnd = (boxSize - longestString) % 2 == 0 ? paddingStart : paddingStart + " "
            
            // write the line
            for j in 0..<2^^i {
                cur += paddingStart + strHelp[i][j] + paddingEnd
            }
            
            // add the connection line
            if !firstLine {
                // whitespaces
                let gapStartSize = (boxSize*2-2) / 3
                var gapStart = ""
                for _ in 0 ..< gapStartSize {
                    gapStart += " "
                }
                var gapEnd = gapStart
                for _ in 3*gapStartSize ..< boxSize*2-2 {
                    gapEnd += " "
                }
                
                var conLn = ""
                for j in 0..<2^^(i-1) {
                    conLn += gapStart
                    conLn += help[i][j*2] == nil ? " " : "/"
                    conLn += gapStart
                    conLn += help[i][j*2+1] == nil ? " " : "\\"
                    conLn += gapEnd
                }
                lines.append(conLn)
            }
            
            lines.append(cur)
            
            firstLine = false
        }
        
        // print lines
        for l in lines {
            print(l)
        }
    }
}


public extension AVLTree {
    public func toList() -> [T] {
        return root.toList()
    }
    
    /**
     Prints this AVLTree nicely to the console
     */
    public func printTree() {
        return root.printTree()
    }
}

private enum BalanceType {
    case Left, Center, Right
    init(_ arg: Int) {
        self = arg < -1 ? .Left : arg > 1 ? .Right : .Center
    }
}
