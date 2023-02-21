// Load Address of LED into R0
lbi R0, 0xC0
slbi R0, 0x04

lbi R1, 0xAA
st R1, R0, 0x0
lbi R1, 0x55
st R1, R0, 0x0

.FAIL:
J .FAIL

