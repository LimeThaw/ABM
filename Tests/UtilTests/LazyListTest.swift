//
//  LazyListTest.swift
//  ABM
//
//  Created by Tierry Hörmann on 28.04.17.
//
//

import XCTest
@testable import Util

class LazyListTest: XCTestCase {
    #if os(Linux)
    static var allTests = {
    return [
    ("test_prepend", test_prepend),
    ("test_append", test_append)
    ]
    }()
    #endif
    
    typealias LL = LazyList<Int>
    var rand = Random()
    
    func test_prepend() {
        let gen = generateRandomList(ofSize: 50, maxEntry: 100)
        let testArray = gen.0.toArray()
        XCTAssert(testArray == gen.1, "The two arrays don't match each other: \(testArray), \(gen.1)")
    }
    
    func test_append() {
        var array: [Int] = []
        var list = LL()
        let appends = rand.next(max: 30)
        for _ in 0..<appends {
            let gen = generateRandomList(ofSize: 50, maxEntry: 100)
            list = list + gen.0
            array += gen.1
        }
        XCTAssert(list.toArray() == array)
    }
    
    func test_count() {
        let gen = generateRandomList(ofSize: 50, maxEntry: 100)
        XCTAssert(gen.0.count == gen.1.count)
    }
    
    func generateRandomList(ofSize maxSize: Int, maxEntry: Int) -> (LL, [Int]) {
        var ll = LL()
        var array: [Int] = []
        let size = rand.next(max: maxSize)
        for _ in 0..<size {
            let next = rand.next(max: maxEntry)
            ll = next <- ll
            array.append(next)
        }
        return (ll, array.reversed())
    }
}
