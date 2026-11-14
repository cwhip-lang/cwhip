# Exercises independent base subobjects and qualified field access in a non-virtual diamond.
class Node {
    public:
    int64 value

    Node(int64 initial) {
        value = initial
    }
}

class Root {
    public:
    Node item
    int64 value

    int64 read() {
        return(value)
    }
}

class Left : Root {
    public:
    int64 left

    int64 sum() {
        return(value + left)
    }
}

class Right : Root {
    public:
    int64 right

    int64 sumRight() {
        return(value + right)
    }
}

class Diamond : Left, Right {
    public:
    int64 extra

    int64 sum() {
        return(left + extra)
    }
}

start {
    Diamond diamond = Diamond()
    diamond.Left.Root.item = Node(10)
    diamond.Right.Root.item = Node(20)
    diamond.Left.Root.value = 10
    diamond.Right.Root.value = 20
    diamond.Left.left = 2
    diamond.Right.right = 3
    diamond.extra = 5

    Left leftView = diamond
    print(leftView.sum())
    print(diamond.Left.sum())
    print(diamond.Left.Root.item.value)
    print(diamond.Right.Root.item.value)
    print(diamond.Right.right)
}
