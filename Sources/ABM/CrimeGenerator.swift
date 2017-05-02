//
//  CrimeGenerator.swift
//  ABM
//
//  Created by Tierry Hörmann on 30.03.17.
//
//

import Util
import Foundation

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
        if type == CrimeType.Murder {
            return { prev, cur, ext in
                if ext <= 0 {
                    return false
                }
                cur.cma.pleasure -= 0.2*ext
                cur.moral -= 0.01*ext
                return true
            }
        } else {
            return { prev, cur, ext in
                if ext <= 0 {
                    return false
                }
                cur.cma.pleasure -= 0.001*ext
                return true
            }
        }
    }

    private func propagate(from source: GraphNode<Agent>..., until reach: Int) {
        let propFunc = getPropagationFunction()
        // holds an array with tuples which hold the next agents to be modified as a second argument, the previous agent that calls the next agent to be modified as a first argument, the edge between the next and the previous agent and the remaining iterations.
        var next = Queue<(GraphNode<Agent>, GraphNode<Agent>, Edge<Agent>, Int)>()
        // all the visitedNodes
        var visited: [Agent] = []
        for a in source {
            a.value.visited = true
            visited.append(a.value)
            for n in a.edges {
                next.insert((a, n.value.next, n.value, reach-1))
            }
        }

        while !next.isEmpty {
            let cur = next.remove()!
            if !cur.1.value.visited {
                if propFunc(cur.0.value, cur.1.value, Float(cur.3)*Float(cur.3)*cur.2.weight/2) {
                    for nextEdge in cur.1.edges {
                        if !nextEdge.value.next.value.visited {
                            next.insert((cur.1, nextEdge.value.next, nextEdge.value, cur.3-1))
                        }
                    }
                }
                cur.1.value.visited = true
                visited.append(cur.1.value)
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
        let crimeStart = {(initiator: Agent, victim: Agent, ext: Int) -> GraphNode<Agent>? in
            let succVal = increaseProbability(rand.nextProb(), by: positive(fromFS: initiator.enthusiasm))
            let outcome = self.type.getOutcome(val: succVal, for: self.weapon)
            initiator.cma = self.type.actualUpdate(attributes: initiator.cma, for: outcome, by: ext)
            if outcome == OutcomeType.Fail {
                return nil
            } else {
                return graph.find(node: victim)! // requires that the agent is in the graph
            }
        }

        if type == CrimeType.Murder{
            return { ini, vic, ext in
                if let node = crimeStart(ini, vic, ext) {
                    ini.moral += 0.5
                    self.propagate(from: node, until: 4)
                    graph.removeNode(node: node)
                    for nextEdge in node.edges {
                        nextEdge.value.next.value.updateConnectedness(node: nextEdge.value.next)
                    }
                }
            }
        } else {
            return { ini, vic, ext in
                if let node = crimeStart(ini, vic, ext) {
                    ini.enthusiasm += 0.1
                    vic.cma.pleasure -= 0.16*Float(ext)
                    vic.moral -= 0.1
                    self.propagate(from: node, until: Int(sqrt(Double(ext))))
                }
                ini.enthusiasm -= 0.1
                ini.moral += 0.1
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

    mutating func setDifficulty(_ d: Float, _ f: Float) {
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
        actualCost = Emotion(-0.6, 0.5, -0.2)
        actualGain = Emotion(-0.2, 0.1, -0.1)
        wishedCost = Emotion(-0.5, -0.5, 0)
        wishedGain = Emotion(0.5, -0.5, 0.2)
    }
}

/**
The following struct defines the possible crime types. The direct effect on the initiator
(change of CMA) is stored in an instance, the effect on the victim and its surroundings are coded
in the generate crime function
*/
struct CrimeType: CustomStringConvertible {

    var description: String {
        switch type {
        case .Murder:
            return "Murder"
        case .Other:
            return "Other"
        }
    }

    private enum TypeE {
        case Murder
        case Other
    }

    let attributes: CrimeAttributes
    private let type: TypeE

    static let Murder = CrimeType(.Murder)
    static let Other = CrimeType(.Other)

    static let all = [Murder, Other]

    private init(_ t: TypeE) {
        switch t {
        case .Murder:
            var at = CrimeAttributes()
            at.actualCost = Emotion(-1.5, 0, -0.4)
            at.actualGain = Emotion(-1, 0.2, 0.2)
            at.wishedCost = Emotion(-1, -0.5, -1)
            at.wishedGain = Emotion(0.5, -0.5, 0.5)
            at.setDifficulty(0.9, 0.4)
            at.isExtendable = false
            attributes = at
        case .Other:
            attributes = CrimeAttributes()
        }
        type = t
    }

    static func ==(lhs: CrimeType, rhs: CrimeType) -> Bool {
        return lhs.type == rhs.type
    }

    /**
     Returns the new CMA when the crime was executed
     - parameter attributes: the old CMA
     - parameter for: the outcome type
     - parameter by: the extend of the crime
    */
    fileprivate func actualUpdate(attributes: CMA, for outcome: OutcomeType, by ext: Int) -> CMA{
        var actualExtend = Float(ext)
        if !self.attributes.isExtendable {
            actualExtend = 1
        }
        switch outcome {
        case .Fail:
            return attributes + self.attributes.actualCost*actualExtend
        case .Partially:
            let ret = attributes + self.attributes.actualCost*actualExtend
            return ret + self.attributes.actualGain*actualExtend
        default:
            return attributes + self.attributes.actualGain*actualExtend
        }
    }

    /**
     Returns the new CMA that the initiator thinks he will get with the given outcome and extend
     - parameter attributes: the old CMA
     - parameter for: the outcome type
     - parameter by: the extend of the crime
     */
    func wishedUpdate(attributes: CMA, for outcome: OutcomeType, by ext: Int) -> CMA{
        var actualExtend = Float(ext)
        if !self.attributes.isExtendable {
            actualExtend = 1
        }
        switch outcome {
        case .Fail:
            return attributes + self.attributes.wishedCost*actualExtend
        case .Partially:
            let ret = attributes + self.attributes.wishedCost*actualExtend
            return ret + self.attributes.wishedGain*actualExtend
        default:
            return attributes + self.attributes.wishedGain*actualExtend
        }
    }

    /**
     Returns the outcome for a given success value
     - parameter val: The success value. 0 is guaranteed failure, 1 is guaranteed success
    */
    func getOutcome(val: Float, for weapon: Weapon) -> OutcomeType {
        assert(val >= 0 && val <= 1, "Illegal value: \(val)")
        let successValue = increaseProbability(val, by: weapon.rawValue)
        return successValue < attributes.failRate ? .Fail : successValue < attributes.difficulty ? .Partially : .Success
    }
}
