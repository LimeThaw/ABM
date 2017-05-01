//
//  Stack.swift
//  ABM
//
//  Created by Tierry Hörmann on 30.04.17.
//
//

public struct Stack<T> {
    private var data = LazyList<T>()
    
    public init(){}
    
    public func peek() -> T? {
        return data.hd
    }
    
    public mutating func push(_ val: T) {
        data = val <- data
    }
    
    @discardableResult
    public mutating func pop() -> T {
        precondition(!isEmpty, "Can't pop from empty stack")
        let ret = peek()!
        data = data.tl
        return ret
    }
    
    public var isEmpty: Bool {
        get {return data.isEmpty()}
    }
    
    public var count: Int {
        get {return data.count}
    }
}
