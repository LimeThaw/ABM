//
//  LL.swift
//  ABM
//
//  Created by Tierry Hörmann on 22.03.17.
//
//

import Foundation

/// A singly linked list that computes its tail only when needed
public struct LazyList<T> {
    fileprivate let root: LLE<T>
    
    /// Initializes this list with a given root, accumulator and lazy counter
    fileprivate init(_ root: LLE<T>, _ accu: Int, _ cnt: @escaping () -> Int) {
        self.root = root
        self.hd = root.val()
        self.lazyCounter = cnt
        self.accumulator = accu
        memoizedTail = memoize( {LazyList<T>(root.tail()(), accu-1, cnt)} )
        memoizedCount = memoize( {accu + cnt()} )
    }
    
    public init() {
        self.init(LLE<T>.End, 0, {0})
    }
    
    public let hd: T?

    private let memoizedTail: () -> LazyList<T>
    public var tl: LazyList<T> {
        get {
            return memoizedTail()
        }
    }
    
    // The counter of the lazy list is composed of an accumulator, which is updated, when there is a known difference to the new count, and a lazyCounter, which needs some computation before its value is known, because it first needs to evaluate some closures
    fileprivate let accumulator: Int
    fileprivate let lazyCounter: () -> Int
    /// the memoizing function that counts the length of this list
    private let memoizedCount: () -> Int
    /**
     Returns the length of this lazy list. Requesting this property forces the list to be evaluated as far as required to identify the length (which might be a lot when lazy append and prepend were used).
     Therefore request this property only when really needed (or when no append or prepend was used) and use other methods, like isEmpty() instead when possible.
    */
    public var count: Int {
        get {
            return memoizedCount()
        }
    }
}

public extension LazyList {
    
    /// Returns whether this list is empty or not in constant time.
    public func isEmpty() -> Bool {
        switch root {
        case .End:
            return true
        default:
            return false
        }
    }
}

/// A structure that can iterate over a list
public struct ListIterator<T>: IteratorProtocol {
    private var list: LazyList<T>
    
    public init(_ l: LazyList<T>) {
        list = l
    }
    
    public mutating func next() -> T? {
        if list.isEmpty() {
            return nil
        } else {
            let ret = list.hd!
            list = list.tl
            return ret
        }
    }
}

extension LazyList: Sequence {
    public func makeIterator() -> ListIterator<T> {
        return ListIterator<T>(self)
    }

    public func toArray() -> [T] {
        var array: [T] = []
        array.reserveCapacity(self.count)
        for x in self {
            array.append(x)
        }
        return array
    }
}

extension LazyList: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: T...) {
        self.init()
        for element in elements.reversed() {
            self = element <- self
        }
    }
}

/**
 Append operator for this list
 */
public func +<T>(lhs: LazyList<T>, rhs: LazyList<T>) -> LazyList<T> {
    return LazyList<T>(lhs.root + rhs.root, lhs.accumulator + rhs.accumulator, {lhs.lazyCounter() + rhs.lazyCounter()})
}

/**
 Append one element
 */
public func +<T>(lhs: LazyList<T>, rhs: T) -> LazyList<T> {
    return LazyList<T>(lhs.root + .Node(rhs, {.End}), lhs.accumulator+1, lhs.lazyCounter)
}

/**
 Lazy append operator: The right hand side is wrapped to a closure and executed when needed
 */
infix operator ++: AdditionPrecedence
func ++<T>(lhs: LazyList<T>, rhs: @autoclosure @escaping () -> LazyList<T>) -> LazyList<T> {
    // make the function that evaluates the right hand side to a memoizing function
    let memoRHS = memoize(rhs)
    // return the new lazy list
    return LazyList<T>(lhs.root + memoRHS().root, lhs.accumulator, {lhs.lazyCounter() + memoRHS().count})
}

/**
 Prepend operator for this list
 */
infix operator <-: AdditionPrecedence
public func <- <T>(lhs: T, rhs: LazyList<T>) -> LazyList<T> {
    return LazyList<T>(.Node(lhs, {rhs.root}), rhs.accumulator + 1, rhs.lazyCounter)
}

/**
 Lazy prepend operator: The right hand side is wrapped to a closure and executed when needed
 */
infix operator <~: AdditionPrecedence
public func <~ <T>(lhs: T, rhs: @autoclosure @escaping () -> LazyList<T>) -> LazyList<T> {
    // make the function that evaluates the right hand side to a memoizing function
    let memoRHS = memoize(rhs)
    // return the new lazy list
    return LazyList<T>(.Node(lhs, {memoRHS().root}), 1, {memoRHS().count})
}


/// The enum that forms the core of the linked list
private enum LLE<T> {
    case End
    indirect case Node(T, () -> LLE<T>)
    
    func val() -> T? {
        switch self {
        case let .Node(v, _):
            return v
        default:
            return nil
        }
    }
    
    func tail() -> () -> LLE<T> {
        switch self {
        case let .Node(_, tl):
            return tl
        default:
            assert(false, "Can't call tail on empty list")
            return {self}
        }
    }
}

private func +<T>(lhs: LLE<T>, rhs: @autoclosure @escaping () -> LLE<T>) -> LLE<T> {
    switch lhs {
    case .End:
        return rhs()
    case let .Node(v, tl):
        return .Node(v, {tl()+rhs()})
    }
}
