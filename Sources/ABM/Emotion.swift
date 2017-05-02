import Foundation
import Util

struct Emotion {

	init(_ P: Float, _ A: Float, _ D: Float) {
		pleasure = P
		arousal = A
		dominance = D
	}

	init() {
		self.init(
			Float(rand.nextNormal(mu: 0.5, sig: 0.5)),
			Float(rand.nextNormal(mu: 0.5, sig: 0.5)),
			Float(rand.nextNormal(mu: 0.5, sig: 0.5))
		)
	}

	var pleasure: Float
	var arousal: Float
	var dominance: Float
}

infix operator *
func *(left: Emotion, right: Float) -> Emotion {
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