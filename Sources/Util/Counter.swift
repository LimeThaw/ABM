/// A simple counter
public struct Counter: Sequence, IteratorProtocol {
    /// The current value of this counter
    public private(set) var cur: Int
    
    /**
     Creates a new counter with the specified starting value
     - parameter start: The initial value of this counter
    */
    public init(_ start: Int){
        cur = start
    }
    /**
     Creates a new counter with a start value of 0.
    */
    public init(){
        self.init(0)
    }
    
    /**
     Counts this counter up by one and returns the new value
     - returns: the next value of this counter or nil if the current value is equal to Int.max
    */
    public mutating func next() -> Int? {
        if cur == Int.max {
            return nil
        } else {
            cur += 1
            return cur
        }
    }
    
    /**
     Tries to skip this counter by the given amount and returns the amount skipped.
     - parameter by: the amount that should be skipped
     - returns: the amount skipped
     */
    public mutating func skip(by: Int) -> Int {
        if Int.max - cur < by {
            cur = Int.max
            return Int.max - cur
        }
        cur += by
        return by
    }
}
