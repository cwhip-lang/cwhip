# Merges an included namespace fragment with a local declaration and calls both classes.
include "../includes/namespace_fragment.cw"

namespace Included {
    class Local {
        public:
        int64 value() {
            return(2)
        }
    }
}

start {
    Included.Remote remote = Included.Remote()
    Included.Local local = Included.Local()
    print(remote.value() + local.value())
}
