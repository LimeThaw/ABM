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
        let gen = generateRandomList()
        let testArray = gen.0.toArray()
        let array = gen.1
        XCTAssert(testArray == array, "The two arrays don't match each other: \(testArray), \(array)")
    }
    
    func test_append() {
        var array: [Int] = []
        var list = LL()
        let appends = rand.next(max: 100)
        for _ in 0..<appends {
            let gen = generateRandomList()
            list = list ++ gen.0
            array += gen.1
        }
        XCTAssert(list.toArray() == array)
    }
    
    func test_count() {
        let gen = generateRandomList()
        XCTAssert(gen.0.count == gen.1.count)
    }
    
    func test_performance() {
        for exp in 0...10 {
            let it = 2^^exp
            var list = LL()
            tic()
            for _ in 0..<it {
                list = list + generateRandomList(lazy: false, randomSize: false).0
            }
            print("Append for \(it) iterations: \(tocS())s")
            list = LL()
            tic()
            for _ in 0..<it {
                list = rand.next(max: 1000) <- list
            }
            print("Prepend for \(it) elements: \(tocS())s")
        }
    }
    
    func generateRandomList(ofSize maxSize: Int = 100, maxEntry: Int = 1000, lazy: Bool = true, randomSize: Bool = true) -> (LL, [Int]) {
        var ll = LL()
        var array: [Int] = []
        let size = randomSize ? rand.next(max: maxSize) : maxSize
        for _ in 0..<size {
            let next = rand.next(max: maxEntry)
            if lazy {
                let cur = ll
                ll = next <~ cur
            } else {
                ll = next <- ll
            }
            array.append(next)
        }
        return (ll, array.reversed())
    }
}
