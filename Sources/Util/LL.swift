//
//  LL.swift
//  ABM
//
//  Created by Tierry Hörmann on 22.03.17.
//
//

import Foundation

enum LLE<T> {
    case End
    indirect case Node(T, LLE<T>)
    init(val: T){
        self = .Node(val, .End)
    }
    
    func prepend(val: T) -> LLE<T>{
        return .Node(val, self)
    }
}

private class No<T> {
    var val: T
    var next: No<T>?
    init(_ v: T, next: No<T>?){
        val = v
        self.next = next
    }
}

class LL<T> {
    private var first: No<T>
    
    init(val: T){
        first = No<T>(val, next: nil)
    }
    
    func prepend(val: T) {
        first = No<T>(val, next: first)
    }
}
