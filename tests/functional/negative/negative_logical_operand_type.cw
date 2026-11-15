/*
 * tests/functional/negative/negative_logical_operand_type.cw
 *
 * Rejects non-boolean operands to keyword and symbolic logical operators.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg value = "not an integer"
    bool invalid = value and true
}
