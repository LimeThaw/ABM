import XCTest
@testable import Util

/**
 Tests for the purely functional AVLTree
 */
class AVLTreeTest : XCTestCase {
    #if os(Linux)
    static var allTests = {
       return [
            ("test_insert", test_insert),
            ("test_contains", test_contains),
            ("test_delete", test_delete),
            ("test_toList", test_toList),
            ("test_removeSmallest", test_removeSmallest),
            ("test_removeLargest", test_removeLargest)
        ]
    }()
    #endif
    
    /**
     Tests whether the given tree satisfies invariants of an AVLTree
     - parameter tree: the tree to test for invariants
    */
    func invariants(_ tree: AVLTree<Int>){
        switch tree.root {
        case let .Node(v, l, r, h):
            let lh = l.height()
            let rh = r.height()
            XCTAssert(abs(rh-lh) <= 1, "invalid balance: \(rh-lh)")
            XCTAssert(lh+1 == h || lh + 2 == h, "invalid left height: \(lh) with own height: \(h)")
            XCTAssert(rh+1 == h || rh + 2 == h, "invalid right height: \(rh) with own height: \(h)")
            let lv = l.value()
            let rv = r.value()
            XCTAssert(lv == nil || lv! < v, "invalid left value: \(lv) with own value: \(v)")
            XCTAssert(rv == nil || rv! > v, "invalid right value: \(rv) with own value: \(v)")
        default:
            XCTAssert(true)
        }
    }
    
    /**
     Tests whether the given tree and all its subtrees satisfies invariants of an AVLTree
     - parameter tree: The tree to be checked
    */
    func invariantsRecursive(_ tree: AVLTree<Int>){
        func help(_ tree: AVLTreeNode<Int>){
        switch tree {
        case let .Node(_, l, r, _):
            invariants(AVLTree<Int>(tree))
            invariantsRecursive(AVLTree<Int>(l))
            invariantsRecursive(AVLTree<Int>(r))
        default:
            XCTAssert(true)
        }
        }
        help(tree.root)
    }
    
    /**
     Inserts a value into a tree and checks the invariants
     - parameter value: the value to be inserted
     - parameter into: the tree where it should be inserted
     - returns: the tree with the inserted value
    */
    func insert(value v: Int, into t: AVLTree<Int>) -> AVLTree<Int> {
        let res = t.insert(v)
        invariants(res)
        return res
    }
    
    func delete(value v: Int, from t: AVLTree<Int>) -> AVLTree<Int> {
        let res = t.delete(v)
        invariants(res)
        return res
    }
    
    /**
     Generates a tree with random entries
     - parameter size: The maximum size of the tree
     - returns: A tree with random entries
    */
    func generateRandomTree(size: Int) -> AVLTree<Int> {
        return generateRandomTreeWithList(size: size).0
    }
    
    /**
     Generates a tree with random entries and returns the list with the numbers inserted
     - parameter size: The maximum size of the tree
     - returns: A tuple with a tree with random entries and a list with those entries
     */
    func generateRandomTreeWithList(size: Int) -> (AVLTree<Int>, [Int]) {
        var tree = AVLTree<Int>()
        var rand = Random()
        var array: [Int] = []
        for _ in 0...rand.next(max: size) {
            let val: Int = rand.next()
            tree = insert(value: val, into: tree)
            array.append(val)
        }
        return (tree, array)
    }
    
    /**
     Tests the convertion of a tree to a list
    */
    func test_toList(){
        let tmp = generateRandomTreeWithList(size: 1000)
        XCTAssert(tmp.0.toList() == tmp.1.sorted())
    }
    
    /**
     Tests the insert functionality
    */
    func test_insert(){
        var tree = AVLTree<Int>()
        let min = -100
        let max = 100
        let entries: [Int] = Array(min...max)
        var remaining = entries
        var rand = Random()
        
        // insert entries in random order
        for _ in 0...(max-min) {
            tree = insert(value: remaining.remove(at: rand.next() % remaining.count), into: tree)
        }
        invariantsRecursive(tree)
        
        // the list representation must again be equal to the original (ordered) array
        XCTAssert(tree.toList() == entries)
    }
    
    /**
     Tests the contains function
    */
    func test_contains(){
        var rand = Random()
        let maxIterations = 100
        let tmp = generateRandomTreeWithList(size: 1000)
        let tree = tmp.0
        let array = tmp.1
        for _ in 0...rand.next(max: maxIterations) {
            // test equally if contains and if does not contain
            if rand.next() {
                XCTAssert(tree.contains(array[rand.next(max: array.count)]))
            } else {
                while array.contains(rand.next()) {}
                XCTAssert(!tree.contains(rand.current))
            }
        }
    }
    
    /**
     Tests the removeSmallest function
    */
    func test_removeSmallest(){
        let tmp = generateRandomTreeWithList(size: 1000)
        let array = tmp.1.sorted()
        var tree = tmp.0
        for x in array {
            XCTAssert(tree.contains(x))
            let ret = tree.removeSmallest()
            XCTAssert(ret.0! == x)
            tree = ret.1
            XCTAssert(!tree.contains(x))
            invariantsRecursive(tree)
        }
    }
    
    /**
     Tests the removeLargest function
     */
    func test_removeLargest(){
        let tmp = generateRandomTreeWithList(size: 1000)
        let array = tmp.1.sorted(by: >)
        var tree = tmp.0
        for x in array {
            XCTAssert(tree.contains(x))
            let ret = tree.removeLargest()
            XCTAssert(ret.0! == x)
            tree = ret.1
            XCTAssert(!tree.contains(x))
            invariantsRecursive(tree)
        }
    }
    
    /**
     Tests the delete function
    */
    func test_delete(){
        var rand = Random()
        let maxIterations = 100
        let tmp = generateRandomTreeWithList(size: 1000)
        var tree = tmp.0
        var array = tmp.1
        for _ in 0...abs(rand.next(max: maxIterations)) {
            let val = array.remove(at: rand.next(max: array.count))
            XCTAssert(tree.contains(val))
            tree = delete(value: val, from: tree)
            XCTAssert(!tree.contains(val))
        }
    }
}
