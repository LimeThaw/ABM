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
    moral: (-4.2622542445819702, 3.4810815090480847),
    p: (1.3556664616187657, 8.7657570594990517),
    a: (8.2471501029646817, 1.7875767246530458),
    d: (4.5236066220039746, 0.11783115717011376),
    baseGain: 0.34535768009132711,
    baseCost: 0.95861243728283441,
    edges: 9,
    edgeWeight: 5.8615959018665356,
    weightDec: 0.22607543810101494,
    maxDecExt: 1.393571496553806,
    incGun: 1.4445897001508325
)

let pars2 = Parameters((-1.1783762635362867, 1.8594696385614404), (8.6612415111464287, 7.665202511775302), (-9.3667311834704741, 1.9275271023268232), (0.19419164646229747, 6.3382189673339795), 0.67975943795153482, 1.2878498086882491, 6, 6.3240268137830142, 0.82085440244463337, 0.53034435382111134, 0.66871126019599747)

//try! runSimulation(pars2, days: 365*10, g: loadGraph(from: URL(fileURLWithPath: "graph.txt")))
runSimulation(pars2, days: 365*3, population: 10000)
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
