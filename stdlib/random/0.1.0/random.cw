namespace Random {
    class SecureRandom {
        public:
        buffer bytes(int64 size)
        bool fill(buffer target)
    }

    buffer SecureRandom.bytes(int64 size) from "cwhip_random_bytes"
    bool SecureRandom.fill(buffer target) from "cwhip_random_fill"
}
