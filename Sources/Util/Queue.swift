//
//  Queue.swift
//  ABM
//
//  Created by Tierry Hörmann on 12.04.17.
//
//

/*public struct PFQueue<T> {
    fileprivate var data = LazyList<T>()

    public init(){}

    public var count: Int {
        get { return data.count }
    }

    public var isEmpty: Bool {
        get { return data.isEmpty() }
    }

    public mutating func insert(_ elem: T){
        data = data + elem
    }

    public mutating func remove() -> T? {
        let ret = data.hd
        data = data.tl
        return ret
    }
}*/

public struct Queue<T> {
    private var first: QNode<T>?
    private var last: QNode<T>?
    public private(set) var count = 0
    public var isEmpty: Bool {
        get { return count == 0 }
    }

    public init(){}

    public mutating func insert(_ val: T) {
        if isEmpty {
            first = QNode<T>(val: val, next: nil, prev: nil)
            last = first
        } else {
            let l = QNode<T>(val: val, next: last!, prev: nil)
            last!.prev = l
            last = l
        }
        count += 1
    }

    public mutating func remove() -> T? {
        if isEmpty {
            return nil
        }
        let f = first!
        first = f.prev
        if first != nil {
            first!.next = nil
        } else {
            last = nil
        }
        count -= 1
        return f.val
    }
}

private class QNode<T> {
    let val: T
    var next: QNode<T>?
    var prev: QNode<T>?
    init(val: T, next: QNode<T>?, prev: QNode<T>?) {
        self.val = val
        self.next = next
    }
}
