/*
 * tests/functional/negative/negative_raise_legacy_syntax.cw
 *
 * Rejects raise legacy syntax.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
  raise "bare raises are no longer supported"
}
