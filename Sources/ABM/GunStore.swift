//
//  GunStore.swift
//  ABM
//
//  Created by Tierry Hörmann on 16.05.17.
//
//

/**
 Returns whether an agent can legally buy a gun
 */
func canBuyGun(_ a: Agent) -> Bool {
	if a.age < 21*365 {
		if CHECK_HYPOTHESIS_2 {
			return a.criminalHistory ? false : true
		} else {
    		return true
		}
	} else {
		return false
	}
}
