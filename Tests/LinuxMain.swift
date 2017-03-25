//
//  LinuxMain.swift
//  ABM
//
//  Created by Tierry Hörmann on 25.03.17.
//
//
#if os(Linux)
    import XCTest
    @testable import TreeTests
    
    XCTMain([testCase(AVLTreeTest.allTests)])
#endif
