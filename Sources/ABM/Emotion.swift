import Foundation
import Util

struct Emotion {

	var pleasure: Double
	var arousal: Double
	var dominance: Double

	init(_ P: Double, _ A: Double, _ D: Double) {
		pleasure = P
		arousal = A
		dominance = D
	}

	init() {
		let mu = attributeBound.0 + ((attributeBound.1 - attributeBound.0)/2)
		let sig = attributeBound.1 - mu / 5 // The 5 here is arbitrary
		self.init(
			Double(rand.nextNormal(mu: mu, sig: sig)),
			Double(rand.nextNormal(mu: mu, sig: sig)),
			Double(rand.nextNormal(mu: mu, sig: sig))
		)
	}
}

// Adding emotional states componentwise with assignment
func +=( left: inout Emotion, right: (Double, Double, Double)) {
    left = Emotion(
        fitToRange(left.pleasure+right.0, range: attributeBound),
        fitToRange(left.arousal+right.1, range: attributeBound),
        fitToRange(left.dominance+right.2, range: attributeBound)
    )
}

// Subtracting emotional states componentwise with assignment
func -=( left: inout Emotion, right: (Double, Double, Double)) {
    left += (-right.0, -right.1, -right.2)
}

// Adding emotional states componentwise
infix operator *
func *(left: Emotion, right: Double) -> Emotion {
	return Emotion (
		left.pleasure * right,
		left.arousal * right,
		left.dominance * right
	)
}

// Subtracting emotional states componentwise
infix operator +
func +(left: Emotion, right: Emotion) -> Emotion {
	return Emotion(
		left.pleasure + right.pleasure,
		left.arousal + right.arousal,
		left.dominance + right.dominance
	)
}
