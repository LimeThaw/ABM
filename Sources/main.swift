var tree = AVLTree<Int>.Leaf
for i in 0...10 {
    tree = tree.insert(val: i)
}
print(tree.toList())
