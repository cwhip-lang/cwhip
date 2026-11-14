# Uses same-named classes in sibling namespaces and verifies their qualified identities remain distinct.
namespace Branch {
    namespace Left {
        class Item {
            public:
            int64 value() {
                return(10)
            }
        }
    }
}

namespace Branch {
    namespace Right {
        class Item {
            public:
            int64 value() {
                return(32)
            }
        }
    }
}

start {
    Branch.Left.Item left = Branch.Left.Item()
    Branch.Right.Item right = Branch.Right.Item()
    print(left.value() + right.value())
}
