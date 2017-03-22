
func test_all() {
	// AVL tree testing
	let tree = AVLTree<Int>()
	for i in 0...10 {
		print(i)
		tree.insert(value: i)
		print(tree.to_list())//tree.print()
		print("\n")
	}
}