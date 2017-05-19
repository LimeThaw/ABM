//
//  RAHT.swift
//  ABM
//
//  Created by Tierry Hörmann on 19.05.17.
//
//

public protocol DynamicHashable: class, Hashable {
    var dynamicHashValue: Int { get set }
}

public struct RAHT<Entry: DynamicHashable> {
    var table: [Entry?] = []
    var data: [Int:Entry] = [:]
    public var count: Int { return data.count }
    var rand: Random
    
    public init(seed: Int? = nil) {
        if let s = seed {
            rand = Random(s)
        } else {
            rand = Random()
        }
    }
    
    private var density: Float { return table.count > 0 ? Float(count)/Float(table.count) : 1}
    private mutating func randomEntry(_ condition: (Entry?) -> Bool = {$0 != nil}) -> Int {
        var hash = 0
        repeat  {
            hash = rand.next(max: table.count)
        } while hash != table.count && !condition(table[hash])
        return hash
    }

    
    public mutating func insert(_ val: Entry) {
        if data[val.hashValue] == nil {
            data[val.hashValue] = val
            if density > 0.7 {
                val.dynamicHashValue = table.count
                table.append(val)
            } else {
                let hash = randomEntry({$0 == nil})
                val.dynamicHashValue = hash
                table[hash] = val
            }
        }
    }
    
    private mutating func shrink() {
        if density < 0.3 && table.last! != nil{
            let last = table.removeLast()!
            let hash = randomEntry({$0 == nil})
            last.dynamicHashValue = hash
            table[hash] = last
        }
        while density < 0.5 && table.last! == nil {
            table.removeLast()
        }
    }
    
    @discardableResult
    mutating func remove(staticHash: Int) -> Entry? {
        assert(staticHash >= 0 && staticHash < table.count)
        if let entry = data.removeValue(forKey: staticHash) {
            let dhash = entry.dynamicHashValue
            table[dhash] = nil
            shrink()
        }
        return nil
    }
    
    @discardableResult
    mutating func remove(_ val: Entry) -> Entry? {
        return remove(staticHash: val.hashValue)
    }
    
    func has(staticHash: Int) -> Bool {
        return data[staticHash] != nil
    }
    
    func get(staticHash: Int) -> Entry? {
        return data[staticHash]
    }
    
    mutating func getRandom() -> Entry? {
        if count == 0 {
            return nil
        }
        return table[randomEntry()]
    }
}

extension RAHT: Sequence {
    public func makeIterator() -> DictionaryIterator<Int, Entry> {
        return data.makeIterator()
    }
    
    public var values: LazyMapCollection<[Int:Entry], Entry> {
        return data.values
    }
}
