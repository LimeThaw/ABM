//
//  CrimeGenerator.swift
//  ABM
//
//  Created by Tierry Hörmann on 30.03.17.
//
//

/**
 A struct that generates crimes.
 This struct defines what a crime exactly is.
*/
struct CrimeGenerator {
    
    private let weapon: Weapon
    private let type: CrimeType
    
    init(with: Weapon, type: CrimeType){
        weapon = with
        self.type = type
    }
    
    /**
     Returns the function that takes a current agent, a previous agent and a extend and returns whether it should be propagated further. For every iteration the extend decreases. This function depends only on the crime type.
     - returns: the propagation function
    */
    private func getPropagationFunction() -> (Agent, Agent, Float) -> Bool {
        switch type {
        case CrimeType.Murder:
            return { prev, cur, ext in
                if ext <= 0 {
                    return false
                }
                cur.cma -= 0.1*ext
                return true
            }
        default:
            return { prev, cur, ext in
                if ext <= 5 {
                    return false
                }
                cur.cma -= 0.01*ext
                return true
            }
        }
    }
    
    private func propagate(from source: Node<Agent>..., until reach: Int) {
        // holds an array with tuples which hold the next agents to be modified as a second argument, the previous agent that calls the next agent to be modified as a first argument, the edge between the next and the previous agent and the remaining iterations.
        var next: [(Node<Agent>, Node<Agent>, Edge<Agent>, Int)] = []
        // all the visitedNodes
        var visited: [Agent] = []
        for a in source {
            a.value.visited = true
            visited += a.value
            for n in a.edgeList() ?? [] {
                next += (cur, n.next, n, reach)
            }
        }
        
        while let cur = next.popLast() {
            if !cur.1.value.visited {
                if getPropagationFunction()(cur.0, cur.1, cur.3*cur.2.weight) {
                    cur.1.value.visited = true
                    visited += cur.1.value
                    for nextEdge in cur.1.edgeList() {
                        if !nextEdge.next.value.visited {
                            next = (cur.1, nextEdge.next, nextEdge, cur.3-1) + next
                        }
                    }
                }
            }
        }
        
        for a in visited {
            a.visited = false
        }
    }
    
    /**
     Generates a crime from the preset attributes.
     A crime is a function that takes an initiator and a victim with an extend. It has a direct influence on the victim and the initiator, i.e. it changes the
     A propagation function takes a source and a target with an iterator which indicates, how far away from the victim the propagation is. The extend on the target should decay exponentially with the iteration and the propagation should be terminated if the extend on the target arrives a given lower bound.
    */
    func generateCrime() -> (Agent, Agent, Int) -> Void {
        
        /// starts the crime, meaning modifies the attributes of the initiator and returns the node of the victim or nil if the crime fails
        let crimeStart = {(initiator: Agent, victim: Agent, ext: Int) -> Node<Agent>? in
            let outcome = type.getOutcome(val: increaseProbability(rand.next(), initiator.enthusiasm), for: weapon)
            initiator.cma = type.actualUpdate(attributes: initiator.cma, for: outcome, by: ext)
            if outcome == OutcomeType.Fail {
                return nil
            } else {
                return graph.find(node: victim)! // requires that the agent is in the graph
            }
        }
        
        switch type {
        case CrimeType.Murder:
            return { ini, vic, ext in
                if let node = crimeStart(ini, vic, ext) {
                    propagate(from: node, until: 8)
                    graph.removeNode(node: node)
                    for nextEdge in node.edgeList() {
                        nextEdge.next.value.updateConnectedness(node: nextEdge.next)
                    }
                }
            }
        default:
            return { ini, vic, ext in
                if let node = crimeStart(ini, vic, ext) {
                    node.value.cma.happiness -= 0.1*ext
                    propagate(from: node, until: 2*ext)
                }
            }
        }
    }
}

enum OutcomeType {
    case Success
    case Partially
    case Fail
}

enum Weapon: Float {
    case Gun = 3.0
    case Other = 1.0
}

/// the following struct defines the attributes of a crime that are important for the initiator
struct CrimeAttributes {
    fileprivate var actualCost: CMA
    fileprivate var actualGain: CMA
    var wishedCost: CMA
    var wishedGain: CMA
    
    /// 1 minus the percentage of success
    private(set) var difficulty: Float
    /// the percentage of failures
    private(set) var failRate: Float
    
    mutating func setDifficulty(_ d: Flot, _ f: Float) {
        assert(f < d && f >= 0 && f < 1 && d > 0 && d <= 1)
        difficulty = d
        failRate = f
    }
    
    /// indicates whether the crime is extendable (e.g. a murder is not extendable)
    var isExtendable: Bool
    
    /// initiates a standard crime
    init() {
        difficulty = 0.6
        failRate = 0.3
        isExtendable = true
        actualCost = -0.2
        actualGain = 0.2
        wishedCost = -0.2
        wishedGain = 0.2
    }
}

/// The following struct defines the possible crime types. The direct effect on the initiator (change of CMA) is stored in an instance, the effect on the victim and its surroundings are coded in the generate crime function
struct CrimeType {
    
    fileprivate enum Type {
        case Murder
        case Other
    }
    
    let attributes: CrimeAttributes
    private let type: Type
    
    static let Murder = CrimeType(.Murder)
    static let Other = CrimeType(.Other)
    
    static let all = [Murder, Other]
    
    private init(_ t: Type) {
        switch t {
        case .Murder:
            var at = CrimeAttributes()
            at.actualCost = -1
            at.actualGain = -0.1
            at.wishedCost = -0.9
            at.wishedGain = 0.5
            at.setDifficulty(0.9, 0.4)
            at.isExtendable = false
            attributes = at
        case .Other:
            attributes = CrimeAttributes()
        default:
            assert(false)
            break
        }
        type = t
    }
    
    static func ==(lhs: CrimeType, rhs: CrimeType) -> Bool {
        lhs.type == rhs.type
    }
    
    /**
     Returns the new CMA when the crime was executed
     - parameter attributes: the old CMA
     - parameter for: the outcome type
     - parameter by: the extend of the crime
    */
    fileprivate func actualUpdate(attributes: CMA, for outcome: OutcomeType, by ext: Int) -> CMA{
        if !attributes.isExtendable {
            ext = 1
        }
        switch outcome {
        case .Fail:
            return attributes + self.attributes.actualCost*ext
        case .Partially:
            return attributes + self.attributes.actualCost*ext
            return attributes + self.attributes.actualGain*ext
        default:
            return attributes + self.attributes.actualGain*ext
        }
    }
    
    /**
     Returns the new CMA that the initiator thinks he will get with the given outcome and extend
     - parameter attributes: the old CMA
     - parameter for: the outcome type
     - parameter by: the extend of the crime
     */
    func wishedUpdate(attributes: CMA, for outcome: OutcomeType, by ext: Int) -> CMA{
        if !attributes.isExtendable {
            ext = 1
        }
        switch outcome {
        case .Fail:
            return attributes + self.attributes.wishedCost*ext
        case .Partially:
            return attributes + self.attributes.wishedCost*ext
            return attributes + self.attributes.wishedGain*ext
        default:
            return attributes + self.attributes.wishedGain*ext
        }
    }
    
    /**
     Returns the outcome for a given success value
     - parameter val: The success value. 0 is guaranteed failure, 1 is guaranteed success
    */
    func getOutcome(val: Float, for weapon: Weapon) -> OutcomeType {
        assert(val >= 0 && val <= 1)
        var successValue = increaseProbability(val, by: weapon)
        return val < type.attributes.failRate ? .Fail : val < type.attributes.difficulty ? .Partially : .Success
    }
}