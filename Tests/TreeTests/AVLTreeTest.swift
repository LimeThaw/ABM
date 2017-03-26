import XCTest
@testable import Util
@testable import Datastructures

/**
 Tests for the purely functional AVLTree
 */
class AVLTreeTest : XCTestCase {
    #if os(Linux)
    static var allTests = {
       return [
            ("test_insert", test_insert),
            ("test_contains", test_contains)
        ]
    }()
    #endif
    
    /**
     Tests whether the given tree satisfies invariants of an AVLTree
     - parameter tree: the tree to test for invariants
    */
    func invariants(_ tree: AVLTree<Int>){
        switch tree {
        case let .Node(v, l, r, h):
            let lh = l.height()
            let rh = r.height()
            XCTAssert(abs(lh-rh) <= 1, "invalid balance: \(rh-lh)")
            XCTAssert(lh+1 == h || lh + 2 == h, "invalid left height: \(lh) with own height: \(h)")
            XCTAssert(rh+1 == h || rh + 2 == h, "invalid right height: \(rh) with own height: \(h)")
            let lv = l.rootValue()
            let rv = r.rootValue()
            XCTAssert(lv == nil || lv! < v, "invalid left value: \(lv) with own value: \(v)")
            XCTAssert(rv == nil || rv! < v, "invalid right value: \(rv) with own value: \(v)")
        default:
            XCTAssert(true)
        }
    }
    
    /**
     Tests whether the given tree and all its subtrees satisfies invariants of an AVLTree
     - parameter tree: The tree to be checked
    */
    func invariantsRecursive(_ tree: AVLTree<Int>){
        switch tree {
        case let .Node(_, l, r, _):
            invariants(tree)
            invariantsRecursive(l)
            invariantsRecursive(r)
        default:
            XCTAssert(true)
        }
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
     - returns: A tree with random entries
    */
    func generateRandomTree(size: Int) -> AVLTree<Int> {
        var tree = AVLTree<Int>()
        var rand = Random()
        for _ in 0...(rand.next() % size) {
            tree = insert(value: rand.next(), into: tree)
        }
        return tree
    }
    
    /**
     Tests the insert functionality
    */
    func test_insert(){
        var tree = AVLTree<Int>()
        let min = -1000
        let max = 1000
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
        let maxIterations = 1000
        let tree = generateRandomTree(size: 10000)
        let array = tree.toList()
        for _ in 0...rand.next(max: maxIterations) {
            // test equally if contains and if does not contain
            if rand.next() {
                XCTAssert(tree.contains(array[rand.next(max: array.count)]))
            } else {
                while array.contains(rand.next(max: array.count)) {}
                XCTAssert(!tree.contains(array[rand.current % array.count]))
            }
        }
    }
    
    /**
     Tests the delete function
    */
    func test_delete(){
        var rand = Random()
        let maxIterations = 1000
        var tree = generateRandomTree(size: 10000)
        var array = tree.toList()
        for _ in 0...rand.next(max: maxIterations) {
            let val = array.remove(at: rand.next(max: array.count))
            tree = delete(value: val, from: tree)
            XCTAssert(!tree.contains(val))
        }
    }
}
