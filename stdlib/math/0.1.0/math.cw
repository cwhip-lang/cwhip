namespace Math {
    class Math {
        public:
        fp64 pi() {
            return(3.141592653589793f64)
        }

        fp64 e() {
            return(2.718281828459045f64)
        }

        fp64 tau() {
            return(6.283185307179586f64)
        }

        fp64 abs(fp64 x)
        int64 absInt(int64 x)
        fp64 min(fp64 a, fp64 b)
        fp64 max(fp64 a, fp64 b)
        int64 minInt(int64 a, int64 b)
        int64 maxInt(int64 a, int64 b)
        fp64 clamp(fp64 x, fp64 minVal, fp64 maxVal)
        fp64 floor(fp64 x)
        fp64 ceil(fp64 x)
        fp64 round(fp64 x)
        fp64 trunc(fp64 x)
        fp64 sqrt(fp64 x)
        fp64 cbrt(fp64 x)
        fp64 pow(fp64 base, fp64 exp)
        fp64 exp(fp64 x)
        fp64 log(fp64 x)
        fp64 log10(fp64 x)
        fp64 log2(fp64 x)
        fp64 sin(fp64 x)
        fp64 cos(fp64 x)
        fp64 tan(fp64 x)
        fp64 asin(fp64 x)
        fp64 acos(fp64 x)
        fp64 atan(fp64 x)
        fp64 atan2(fp64 y, fp64 x)
        fp64 degrees(fp64 radians)
        fp64 radians(fp64 degrees)
        fp64 sinh(fp64 x)
        fp64 cosh(fp64 x)
        fp64 tanh(fp64 x)
    }

    fp64 Math.abs(fp64 x) from "cwhip_math_abs"
    int64 Math.absInt(int64 x) from "cwhip_math_abs_int"
    fp64 Math.min(fp64 a, fp64 b) from "cwhip_math_min"
    fp64 Math.max(fp64 a, fp64 b) from "cwhip_math_max"
    int64 Math.minInt(int64 a, int64 b) from "cwhip_math_min_int"
    int64 Math.maxInt(int64 a, int64 b) from "cwhip_math_max_int"
    fp64 Math.clamp(fp64 x, fp64 minVal, fp64 maxVal) from "cwhip_math_clamp"
    fp64 Math.floor(fp64 x) from "cwhip_math_floor"
    fp64 Math.ceil(fp64 x) from "cwhip_math_ceil"
    fp64 Math.round(fp64 x) from "cwhip_math_round"
    fp64 Math.trunc(fp64 x) from "cwhip_math_trunc"
    fp64 Math.sqrt(fp64 x) from "cwhip_math_sqrt"
    fp64 Math.cbrt(fp64 x) from "cwhip_math_cbrt"
    fp64 Math.pow(fp64 base, fp64 exp) from "cwhip_math_pow"
    fp64 Math.exp(fp64 x) from "cwhip_math_exp"
    fp64 Math.log(fp64 x) from "cwhip_math_log"
    fp64 Math.log10(fp64 x) from "cwhip_math_log10"
    fp64 Math.log2(fp64 x) from "cwhip_math_log2"
    fp64 Math.sin(fp64 x) from "cwhip_math_sin"
    fp64 Math.cos(fp64 x) from "cwhip_math_cos"
    fp64 Math.tan(fp64 x) from "cwhip_math_tan"
    fp64 Math.asin(fp64 x) from "cwhip_math_asin"
    fp64 Math.acos(fp64 x) from "cwhip_math_acos"
    fp64 Math.atan(fp64 x) from "cwhip_math_atan"
    fp64 Math.atan2(fp64 y, fp64 x) from "cwhip_math_atan2"
    fp64 Math.degrees(fp64 radians) from "cwhip_math_degrees"
    fp64 Math.radians(fp64 degrees) from "cwhip_math_radians"
    fp64 Math.sinh(fp64 x) from "cwhip_math_sinh"
    fp64 Math.cosh(fp64 x) from "cwhip_math_cosh"
    fp64 Math.tanh(fp64 x) from "cwhip_math_tanh"
}
