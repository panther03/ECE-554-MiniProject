// Load Address of LED into R0
lbi R0, 0xC0
slbi R0, 0x00

// Check with all the switches off
LD R1, R0, 0x1
BNEZ R1, .FAIL


// Wait for switch 1
NOP
NOP
.CHECK1:
NOP
LD R1, R0, 0x1
SUBI R1, R1, 0x0001
BNEZ R1, .FAIL

// Wait for switch 2
NOP
NOP
.CHECK2:
NOP
LD R1, R0, 0x1
SUBI R1, R1, 0x0002
BNEZ R1, .FAIL


// Wait for switch 3
NOP
NOP
.CHECK3:
NOP
LD R1, R0, 0x1
SUBI R1, R1, 0x0003
BNEZ R1, .FAIL


// Turn on LED 0 and wait for tb to check
LBI R1, 0x0001
ST R1, R0, 0x0
NOP
NOP
NOP
.CHECK4:
NOP

// Turn on LED 2 and wait for tb to check
LBI R1, 0x0002
ST R1, R0, 0x0
NOP
NOP
NOP
.CHECK5:
NOP

HALT

.FAIL:
J .FAIL

