/*
 * examples/package_workflow.cw — Demonstrates package workflow.
 *
 * Created: 2026-10-05
 * Author: chuck
 *
 * Changelog:
 *   2026-10-05  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import system
import math as M

start {
    String message = "packages need no environment activation\n"
    System.System().io().write(message)
    print(M.Math().sqrt(9.0) == 3.0)
}
