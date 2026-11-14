class Window {
    public:
    range<int64> reversed(int64 first, int64 last) {
        return(last..first)
    }
    int64 total(range<int64> values) {
        int64 sum = 0
        for (value in values) { sum += value }
        return(sum)
    }
}
start {
    Window window = Window()
    range<int64> selected = window.reversed(3, 5)
    print("saved: {}, total: {}\n", selected, window.total(selected))
    print("4 included: {}, 6 included: {}\n", 4 in selected, 6 in selected)
    // Storage preserves the exact endpoint type; extract it before widening.
    list stored = [selected]
    range<int64> restored = stored[0]
    print("restored: {}\n", restored)
    // Lossless integer promotion chooses int16 for int8 plus uint8 endpoints.
    range<int16> mixed = int8(-1)..uint8(2)
    print("mixed: {}, negative included: {}\n", mixed, -1 in mixed)
}
