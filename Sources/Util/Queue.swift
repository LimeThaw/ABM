//
//  Queue.swift
//  ABM
//
//  Created by Tierry Hörmann on 12.04.17.
//
//

public struct Queue<T> {
    fileprivate var data = LazyList<T>()
    
    public init(){}
    
    public var count: Int {
        get { return data.count }
    }
    
    public var isEmpty: Bool {
        get { return data.isEmpty() }
    }
    
    public mutating func insert(_ elem: T){
        data = data + [elem]
    }
    
    public mutating func remove() -> T? {
        let ret = data.hd
        data = data.tl
        return ret
    }
}
