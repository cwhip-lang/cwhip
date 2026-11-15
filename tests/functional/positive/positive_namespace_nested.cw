/*
 * tests/functional/positive/positive_namespace_nested.cw
 *
 * Declares classes in nested namespaces across reopened blocks and uses their
 * qualified names.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Shapes {
    namespace Geometry {

        /*
         * Circle is a class, used as a fixture by this test.
         *
         * Its methods include sides.
         */
        class Circle {
            public:
            /*
             * Returns 1.
             *
             * Takes no parameters.
             *
             * Returns int64.
             */
            int64 sides() {
                return(1)
            }
        }
    }
}

namespace Shapes {
    namespace Geometry {

        /*
         * Rectangle is a class, used as a fixture by this test.
         *
         * Its methods include sides.
         */
        class Rectangle {
            public:
            /*
             * Returns 4.
             *
             * Takes no parameters.
             *
             * Returns int64.
             */
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
