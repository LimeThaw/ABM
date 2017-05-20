//
//  CrimeGenerator.swift
//  ABM
//
//  Created by Tierry Hörmann on 30.03.17.
//
//

import Util
import Foundation


struct CrimeGenerator {

    private typealias CG = CrimeGenerator

    private let ini: Agent
    private let arousal: Double
    private let pleasure: Double
    private let dominance: Double
    private let maxAttr: Double
    private let moral: Double
    private let gunPos: Bool
    private let gunAcq: Bool

    static var baseGain: Double = 0.1
    static var baseCost: Double = 0.15
    static private let costGun: Double = 2.0 + (CHECK_HYPOTHESIS_1 ? HYPOTHESIS_1_PENALTY : 0.0)
    static private let baseProb: Double = 0.54 // from FBI statistics: success rate of violent crimes
    static private let maxExt: Double = 10
    static var maxDecExt: Double = 0.4 // the maximum (percentual) decrease of the success probability with the extend
    static var incGun: Double = 0.1 // the (percentual) increase of the success probability when using a gun
    static private let maxIncA: Double = 0.1 // the maximum (percentual) increase of the success probability with the arousal
    static private let maxIncD: Double = 0.1 // the maximum (percentual) increase of the success probability with the dominance
    static private let decVicGun: Double = 0.2 // the (percentual) decrease of the success probability when the victim has a gun
    static private let gunAcqExt: Double = CG.maxExt/4.0 // the extend of a crime to get a gun
    static private let maxPDecMor: Double = 3 // the maximum decrease of the pleasure update through the moral

    // attributes to help calculations
    private let smallPhiNoGun: Double
    private let smallPhiGun: Double
    private let indivBaseProb: Double
    private let stealsGun: Bool
    private let gunAcqCost: Double
	private let myRand: Random

    init(initiator: Agent, generator: Random) {

        self.ini = initiator
		myRand = generator
        arousal = initiator.emotion.arousal
        pleasure = initiator.emotion.pleasure
        dominance = initiator.emotion.dominance
        maxAttr = attributeBound.1
        moral = initiator.moral * CG.maxPDecMor / (maxAttr * CG.maxExt)
        gunPos = initiator.ownsGun
        let _gunAcq = canBuyGun(initiator)
        gunAcq = _gunAcq

        // pre calculations

        smallPhiNoGun = -CG.maxDecExt/CG.maxExt
        smallPhiGun = CG.incGun/CG.maxExt + smallPhiNoGun
        indivBaseProb = increaseProb(CG.baseProb, by: arousal*CG.maxIncA/maxAttr + dominance*CG.maxIncD/maxAttr)

        stealsGun = !initiator.ownsGun && !_gunAcq
        gunAcqCost = CG.cost(e: CG.gunAcqExt, g: false)
    }

    private static func gain(e: Double) -> Double {
        return CG.baseGain * e
    }

    private static func cost(e: Double, g: Bool) -> Double {
        return CG.baseCost * e + (g ? CG.costGun : 0)
    }

    private func prob(e: Double, g1: Bool, g2: Bool) -> Double { // g1: initiator has gun, g2: victim has gun
        let phi = g1 ? smallPhiGun : smallPhiNoGun
        return increaseProb(indivBaseProb, by: phi - (g2 ? CG.decVicGun : 0))
    }

    func visualizedChange(e: Double, g: Bool) -> Double {
        let p = prob(e: e, g1: g, g2: false) // the initiator assumes that the victim has no gun
        let additional: Double = -e*moral - dominance + ((g && stealsGun) ? gunAcqCost : 0) - (CHECK_HYPOTHESIS_1 && g ? HYPOTHESIS_1_PENALTY : 0)
        return p*(CG.gain(e: e) - pleasure) - (1-p)*CG.cost(e: e, g: g) + additional
    }

    func getExtend(gun: Bool) -> Double {
        let largePhiHlp = indivBaseProb*(-CG.baseGain - CG.baseCost) + CG.baseCost + moral
        let largePhiNoGun = largePhiHlp + indivBaseProb*pleasure*smallPhiNoGun
        let largePhiGun = largePhiHlp + indivBaseProb*(pleasure*smallPhiGun - smallPhiGun*CG.costGun)
        let extHlp = 2*indivBaseProb*(CG.baseGain + CG.baseCost)
        return gun ? largePhiGun/(extHlp*smallPhiGun) : largePhiNoGun/(extHlp*smallPhiNoGun)
    }

    /**
     - returns: A tuple with the calculated extend and gun usage, or nil if no crime will be commited
    */
    func makeDecision() -> (Double, Bool)? {

        // possible decisions

        let _extNoGun = getExtend(gun: false)
        let extNoGun = _extNoGun > CG.maxExt ? CG.maxExt : _extNoGun
        let _extGun = getExtend(gun: true)
        let extGun = _extGun > CG.maxExt ? CG.maxExt : _extGun

        // decision making

        if extNoGun <= 0 && extGun <= 0 { // if a extend is smaller than 0, the extend is not used
            return nil
        }
        let vcNoGun = visualizedChange(e: extNoGun, g: false)
        let vcGun = visualizedChange(e: extGun, g: true)
        let gun = extGun <= 0 ? false : (extNoGun <= 0 ? true : (vcGun > vcNoGun ? true : false))
        let ext = gun ? extGun : extNoGun
        if (gun ? vcGun : vcNoGun) <= 0 {
            return nil
        }
        return (ext, gun)
    }

    /**
     - returns: whether the victim died or not
     */
    @discardableResult
    func executeCrime(on vicNode: GraphNode<Agent>, with ext: Double, gun: Bool) -> Bool {
        //print("==========")
        //print("New crime with extend: \(ext) and using gun: \(gun)")

        // parameters

        let sigGain: Double = 0.5 // standard deviation of the gain
        let sigCost: Double = 0.5 // standard deviation of the cost
        let incDSucc: Double = 1 // increase of the dominance after a successful crime
        let decDFail: Double = 0.7 // decrease of the dominance after a failed crime
        let incA: Double = 1.5 // increase of the arousal after a crime
        let baseDecPVic: Double = 0.15 // base decrease of pleasure for victim
        let baseDecDVic: Double = 0.1 // base decrease of dominance for victim
        let decExtFail: Double = 3 // the factor by which the extend (for the victim) is decreased after a fail
        let maxReach = 3

        // precomputations

        let vic: Agent = vicNode.value
        let succProb = prob(e: ext, g1: gun, g2: vic.ownsGun)
        let success = rand.nextProb() <= succProb
        //print("Success probability: \(succProb)")
        let gunAcqUpdate = (gun && stealsGun && rand.nextProb() > prob(e: CG.gunAcqExt, g1: false, g2: false)) ? gunAcqCost : 0
        let reach = Int(Double(maxReach)*ext/CG.maxExt)

        // update for initiator

        if success {
            ini.emotion += (gunAcqUpdate + rand.nextNormal(mu: CG.gain(e: ext), sig: sigGain), incA, incDSucc)
        } else {
            ini.emotion += (gunAcqUpdate - rand.nextNormal(mu: CG.cost(e: ext, g: gun), sig: sigCost), incA, -decDFail)
			if CHECK_HYPOTHESIS_2 {
				ini.criminalHistory = true
				ini.ownsGun = false
			}
        }
        if gun && !ini.ownsGun {
            ini.ownsGun = true
        }

        // update for victim

        let feltExt = success ? ext : ext / decExtFail
        //let deathProb: Double = feltExt/CG.maxExt
        let vicDeath = rand.nextProb() < feltExt/CG.maxExt // whether the victim dies or not
        //print("Death probability: \(deathProb)")
        let pDec = ext*baseDecPVic
        let dDec = ext*baseDecDVic
        if !vicDeath {
            vic.emotion += (-pDec, 0, -dDec)
        }

        // propagation

        // holds an array with tuples which hold the next agents to be modified as a second argument, the previous agent that calls the next agent to be modified as a first argument, the edge between the next and the previous agent and the remaining iterations.
        var next = Queue<(GraphNode<Agent>, GraphNode<Agent>, Edge<Agent>, Int)>()
        // all the visitedNodes
        var visited: [Agent] = []
        vic.visited = true
        visited.append(vic)
        for n in vicNode.edges {
            next.insert((vicNode, n.value.next, n.value, reach))
        }

        while !next.isEmpty {
            let cur = next.remove()!
            if !cur.1.value.visited {

                // update for neighbor
                // the propagated emotion should only be increased by a max factor of 3 when the weight is high
                let tmp: Double = cur.2.weight*cur.2.weight
                let incFact: Double = 3*tmp/(tmp + 20*cur.2.weight + 1) + 1
                // but should be decreased quadratically
                let decFact: Double = Double((reach + 2 - cur.3)^^2)
                cur.1.value.emotion += (incFact*pDec/decFact, 0, incFact*dDec/decFact)

                if cur.3 > 0 {
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

        // victim death

        if vicDeath {
            graph.removeNode(node: vicNode)
        }

        return vicDeath
    }
}
