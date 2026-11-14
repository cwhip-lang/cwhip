set(CASE_NAME cwhip_rejects_const_uninitialized)
set(CASE_FIXTURE negative_const_uninitialized.cw)
set(CASE_EXPECTED_DIAGNOSTIC [==[variable 'value' may be uninitialized]==])
