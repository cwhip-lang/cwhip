# Declares classes in nested namespaces across reopened blocks and uses their qualified names.
namespace Shapes {
    namespace Geometry {
        class Circle {
            public:
            int64 sides() {
                return(1)
            }
        }
    }
}

namespace Shapes {
    namespace Geometry {
        class Rectangle {
            public:
            int64 sides() {
                return(4)
            }
        }
    }
}

start {
    Shapes.Geometry.Circle circle = Shapes.Geometry.Circle()
    Shapes.Geometry.Rectangle rectangle = Shapes.Geometry.Rectangle()
    print(circle.sides() + rectangle.sides())
}
