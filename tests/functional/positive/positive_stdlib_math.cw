/*
 * tests/functional/positive/positive_stdlib_math.cw — Checks stdlib math.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import math as Math

start {
    Math.Math math = Math.Math()
    print(math.pi() > 3.14 and math.pi() < 3.15)
    print(math.e() > 2.71 and math.e() < 2.72)
    print(math.tau() > 6.28 and math.tau() < 6.29)
    print(math.abs(-1.5) == 1.5)
    print(math.absInt(-7) == 7)
    print(math.min(1.0, 2.0) == 1.0)
    print(math.max(1.0, 2.0) == 2.0)
    print(math.minInt(1, 2) == 1)
    print(math.maxInt(1, 2) == 2)
    print(math.clamp(3.0, 0.0, 2.0) == 2.0)
    print(math.floor(1.8) == 1.0)
    print(math.ceil(1.2) == 2.0)
    print(math.round(1.5) == 2.0)
    print(math.trunc(-1.8) == -1.0)
    print(math.sqrt(9.0) == 3.0)
    print(math.cbrt(8.0) == 2.0)
    print(math.pow(2.0, 3.0) == 8.0)
    print(math.exp(0.0) == 1.0)
    print(math.log(math.e()) > 0.99 and math.log(math.e()) < 1.01)
    print(math.log10(100.0) == 2.0)
    print(math.log2(8.0) == 3.0)
    print(math.sin(0.0) == 0.0)
    print(math.cos(0.0) == 1.0)
    print(math.tan(0.0) == 0.0)
    print(math.asin(0.0) == 0.0)
    print(math.acos(1.0) == 0.0)
    print(math.atan(0.0) == 0.0)
    print(math.atan2(0.0, 1.0) == 0.0)
    print(math.degrees(math.pi()) == 180.0)
    print(math.radians(180.0) == math.pi())
    print(math.sinh(0.0) == 0.0)
    print(math.cosh(0.0) == 1.0)
    print(math.tanh(0.0) == 0.0)
}
