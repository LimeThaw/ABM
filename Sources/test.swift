
func test_all() {
	// AVL tree testing
	var tree = AVLTree<Int>()
	for i in 0...10 {
		print(i)
		tree.insert(value: i)
		print(tree.print())
	}
}