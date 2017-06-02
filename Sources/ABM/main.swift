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
    edges: 9,
    edgeWeight: 5.8615959018665356,
    weightDec: 2,
    maxDecExt: 0.7,
    incGun: 0.5
)

let pars2 = Parameters(moral: (-3.4295638963206927, 6.3888950966009954), p: (-5.6098904054036316, 5.8606846269289647), a: (6.0934994385304329, 7.6242846741732935), d: (-6.5410456074003802, 8.8625741667062989), baseGain: 0.29035714584718736, baseCost: 0.85636631095002558, edges: 7, edgeWeight: 9.2212398061835952, weightDec: 0.39244423907634579, maxDecExt: 1.8944286203958021, incGun: 1.3210408044778112)

//try! runSimulation(pars2, days: 365*10, g: loadGraph(from: URL(fileURLWithPath: "graph.txt")))
runSimulation(pars2, days: 365*5, population: 10_000)
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
