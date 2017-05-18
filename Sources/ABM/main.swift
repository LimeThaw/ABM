//findParameters()

let pars = Parameters((1.1036407690904257, 0.091784825127031566), (0.53793218155978062, 0.35697292759178384), (0.35018538036091595, 0.55565824591527946), (1.0565225617436746, 0.24758267346721496))
runSimulation(pars, population: 100)
/*
// check for pleasure change
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