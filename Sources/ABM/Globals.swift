//
//  Globals.swift
//  ABM
//
//  Created by Tierry Hörmann on 23.03.17.
//
//
import Util

var counter = Counter()
var rand = Random(13579)

// constants


// ABM related

let initialPopulationCount = 100_000

// all the attributes in our ABM lie in this interval. This constant must be in this file, because Globals is in the ABM module
public let attributeBound: (Double, Double) = (-10, 10)

let CHECK_HYPOTHESIS_1 = false
let CHECK_HYPOTHESIS_2 = false


// statistics
