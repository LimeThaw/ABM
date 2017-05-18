//findParameters()

let pars = Parameters((0.992748141, 0.0917848274), (0.288447559, 0.157691628), (0.399068922, 0.867913127), (0.0405847281, 0.150922269))
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

runSimulation(pars, days: 10)
