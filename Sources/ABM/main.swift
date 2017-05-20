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

let pars = Parameters((-3.789778137730623, 2.3853321607713074), (5.0182394120407379, 2.3425160763652353), (-4.515100882919346, 6.4846957341235152), (3.0155494435866235, 1.7811585074898553), 1.3553004156330941, 1.615043266226917, -1, 2.1360586833383381, 0.19994387770691255, 2.7831575526426207, 2.0677789390521721)

runSimulation(pars, days: 365, population: 10000)
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
