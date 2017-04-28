//
//  Queue.swift
//  ABM
//
//  Created by Tierry Hörmann on 12.04.17.
//
//

public struct Queue<T> {
    fileprivate let l: LazyList<T>
    fileprivate let r: LazyList<T>
    
    fileprivate static func rot(_ l: LazyList<T>, _ r: LazyList<T>, _ a: LazyList<T>) -> LazyList<T> {
        if l.isEmpty() {
            return r.hd! <- a
        } else {
            return l.hd! <~ rot(l.tl, r.tl, r.hd! <- a)
        }
    }
}
