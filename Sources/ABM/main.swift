import Util

//findParameters()
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

let pars = Parameters((-4.2622542445819702, 3.4810815090480847), (1.3556664616187657, 8.7657570594990517), (8.2471501029646817, 1.7875767246530458), (4.5236066220039746, 0.11783115717011376), 0.34535768009132711, 0.95861243728283441, 0, 5.8615959018665356, 0.22607543810101494, 1.393571496553806, 1.4445897001508325)

runSimulation(pars, days: 30, population: 10000)
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
