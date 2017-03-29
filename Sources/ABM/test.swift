import Foundation
import Util

func test_all() {
    
    var tree2 = AVLTree<Int>()
    let start2 = DispatchTime.now().uptimeNanoseconds
    for i in 0...1000000 {
        tree2 = tree2.insert(i)
    }
    let end2 = DispatchTime.now().uptimeNanoseconds
    let diff2 = end2 - start2
    print("Tierry time \(diff2)")
    
    // AVL tree testing
    /*
    let tree = AVLTreee<Int>()
    let start1 = DispatchTime.now().uptimeNanoseconds
    for i in 0...1000000 {
        tree.insert(value: i)
    }
    let end1 = DispatchTime.now().uptimeNanoseconds
    let diff1 = end1-start1
    print("Timo   time \(diff1)")
 */
    //print("Difference: \(diff1 - diff2)")
}
