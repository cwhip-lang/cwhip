set(CASE_NAME cwhip_rejects_void_typed_constructor)
set(CASE_FIXTURE negative_void_typed_constructor.cw)
set(CASE_EXPECTED_DIAGNOSTIC [==[negative_void_typed_constructor\.cw:3:8: error: constructor 'SomeClass' must omit the return type; write 'SomeClass\(\.\.\.\)' instead of 'void SomeClass\(\.\.\.\)']==])
