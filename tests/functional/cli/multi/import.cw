/*
 * tests/functional/cli/multi/import.cw — import.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import multi_module as ImportedAlias
start {
    ImportedAlias value = ImportedAlias()
    print(value.get() + 2)
}
