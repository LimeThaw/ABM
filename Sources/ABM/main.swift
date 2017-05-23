import Util
import Foundation

//findParameters()
//randomParameters()

/*
rand = Random()
let lower = attributeBound.0
let range = attributeBound.1 - attributeBound.0
let pars = Parameters(
	(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // moral
	(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // pleasure
	(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // arousal
	(rand.nextProb()*range+lower, rand.nextProb()*range/2.0), // dominance
	rand.nextProb()*2, // base gain
	rand.nextProb()*2, // base cost
	rand.next(max: 10), // Average edges per agent
	rand.nextProb()*10, // Initial weight of edges
	rand.nextProb(), // Edge weight decay rate
	rand.nextProb()*3, // maxDecExt
	rand.nextProb()*3 // incGun
)
*/
let pars = Parameters(
    moral: (1, 2),
    p: (0, 1),
    a: (0, 1),
    d: (0, 1),
    baseGain: 0.34535768009132711,
    baseCost: 1,
    edges: 8,
    edgeWeight: 1.2,
    weightDec: 0.6,
    maxDecExt: 0.7,
    incGun: 0.5
)

let pars2 = Parameters(
    moral: (-2.0907624935680982, 1.8819530126690276),
    p: (-9.7078999104086314, 9.1547063320165076),
    a: (-6.1364933724141766, 8.6502531443900157),
    d: (-5.887136386996918, 8.727453956348171),
    baseGain: 0.11958864933683738,
    baseCost: 0.32784081069362814,
    edges: 9,
    edgeWeight: 0.41052976201796543,
    weightDec: 0.73457498625386874,
    maxDecExt: 2.9190417919633651,
    incGun: 0.22369187185035158
)

let pars3 = Parameters(
    moral: (3, 4),
    p: (4.25, 4.032), // data from http://worldhappiness.report/wp-content/uploads/sites/2/2016/03/HR-V1Ch2_web.pdf
    a: (0, 8),
    d: (0, 8),
    baseGain: 0.11958864933683738,
    baseCost: 0.4,
    edges: 9,
    edgeWeight: 0.41052976201796543,
    weightDec: 0.73457498625386874,
    maxDecExt: 1,
    incGun: 0.4
)

let pars4 = Parameters(
    moral: (8.1219482421875, 5.994140625),
    p: (4.25, 4.032), // data from http://worldhappiness.report/wp-content/uploads/sites/2/2016/03/HR-V1Ch2_web.pdf
    a: (0, 8),
    d: (0, 8),
    baseGain: 0.11955813175871244,
    baseCost: 0.39609375000000002,
    edges: 9,
    edgeWeight: 0.41052976201796543,
    weightDec: 0.73457498625386874,
    maxDecExt: 1.0,
    incGun: 0.40781250000000002
)

// create age distribution
var ages = [(Int, Bool)]()
for _ in 0..<365*100 {
    for i in 0..<ages.count {
        if ages[i].1 && rand.next(prob: deathProb(age: ages[i].0)) {
            ages[i].1 = false
        }
        ages[i].0 += 1
    }
    for _ in 0..<newKids(pop: 100_000) {
        ages.append((0,true))
    }
}

localMin(pars: pars3, precision: 15, ageDist: ages)
//try! runSimulation(pars2, days: 30, g: loadGraph(from: URL(fileURLWithPath: "graph2.txt")))
//runSimulation(ageDist: age, pars4, days: 100)
/*
 check for pleasure change
for i in Int(attributeBound.0)...Int(attributeBound.1) {
    let a = Agent(0, age: 0)
    a.emotion = Emotion(Double(i), 0, 0)
    a.moral = 0
    let g = CrimeGenerator(initiator: a)
    print("Extend with gun for pleasure \(i): \(g.getExtend(gun: true))")
    print("Extend without gun for pleasure \(i): \(g.getExtend(gun: false))")
}

print()

// check for arousal change
for i in Int(attributeBound.0)...Int(attributeBound.1) {
    let a = Agent(0, age: 0)
    a.emotion = Emotion(0, Double(i), 0)
    a.moral = 0
    let g = CrimeGenerator(initiator: a)
    print("Extend with gun for arousal \(i): \(g.getExtend(gun: true))")
    print("Extend without gun for arousal \(i): \(g.getExtend(gun: false))")
}

print()

// check for dominance change
for i in Int(attributeBound.0)...Int(attributeBound.1) {
    let a = Agent(0, age: 0)
    a.emotion = Emotion(0, 0, Double(i))
    a.moral = 0
    let g = CrimeGenerator(initiator: a)
    print("Extend with gun for dominance \(i): \(g.getExtend(gun: true))")
    print("Extend without gun for dominance \(i): \(g.getExtend(gun: false))")
}

print()

// check for moral change
for i in Int(attributeBound.0)...Int(attributeBound.1) {
    let a = Agent(0, age: 0)
    a.emotion = Emotion(0, 0, 0)
    a.moral = Double(i)
    let g = CrimeGenerator(initiator: a)
    print("Extend with gun for moral \(i): \(g.getExtend(gun: true))")
    print("Extend without gun for moral \(i): \(g.getExtend(gun: false))")
}*/
