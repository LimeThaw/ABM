import Foundation
import Util

struct Emotion {

	init(_ P: Double, _ A: Double, _ D: Double) {
		pleasure = P
		arousal = A
		dominance = D
	}

	init() {
		self.init(
			Double(rand.nextNormal(mu: 0.5, sig: 0.5)),
			Double(rand.nextNormal(mu: 0.5, sig: 0.5)),
			Double(rand.nextNormal(mu: 0.5, sig: 0.5))
		)
	}

	var pleasure: Double
	var arousal: Double
	var dominance: Double
}

func +=( left: inout Emotion, right: (Double, Double, Double)) {
    left = Emotion(
        fitToRange(left.pleasure+right.0, range: attributeBound),
        fitToRange(left.arousal+right.1, range: attributeBound),
        fitToRange(left.dominance+right.2, range: attributeBound)
    )
}

func -=( left: inout Emotion, right: (Double, Double, Double)) {
    left += (-right.0, -right.1, -right.2)
}

infix operator *
func *(left: Emotion, right: Double) -> Emotion {
	return Emotion (
		left.pleasure * right,
		left.arousal * right,
		left.dominance * right
	)
}

infix operator +
func +(left: Emotion, right: Emotion) -> Emotion {
	return Emotion(
		left.pleasure + right.pleasure,
		left.arousal + right.arousal,
		left.dominance + right.dominance
	)
}
