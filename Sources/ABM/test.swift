import Foundation
import Util

func test_all() {
    
    var tree2 = AVLTree<Int>()
    let start2 = DispatchTime.now().uptimeNanoseconds
    for i in 0...100000 {
        for j in 0...10 {
            tree2 = tree2.insert(i*j)
        }
        for j in 0...7 {
            tree2 = tree2.delete(i*j)
        }
    }
    let end2 = DispatchTime.now().uptimeNanoseconds
    let diff2 = end2 - start2
    print("Tierry time \(diff2)")
    
	// AVL tree testing
	let tree = AVLTreee<Int>()
    let start1 = DispatchTime.now().uptimeNanoseconds
	for i in 0...100000 {
        for j in 0...10 {
            tree.insert(value: i*j)
        }
	}
    let end1 = DispatchTime.now().uptimeNanoseconds
    let diff1 = end1-start1
    print("Timo time \(diff1)")
    //print("Difference: \(diff1 - diff2)")
}
