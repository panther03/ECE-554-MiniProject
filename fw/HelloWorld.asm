// Load Address of TX/RX buffer into R0
lbi R0, 0xC0
slbi R0, 0x04

// Wait for TX buffer to clear
JAL .WAITFORSPACETX

// Print Hello World (48 65 6C 6C 6F 20 57 6F 72 6C 64)
// H
lbi R1, 0x48
st R1, R0, 0x0

// E
lbi R1, 0x65
st R1, R0, 0x0

// L
lbi R1, 0x6C
st R1, R0, 0x0

// L
lbi R1, 0x6C
st R1, R0, 0x0

// O
lbi R1, 0x6F
st R1, R0, 0x0

// [space]
lbi R1, 0x20
st R1, R0, 0x0

// W
lbi R1, 0x57
st R1, R0, 0x0


// Wait for TX buffer to clear
JAL .WAITFORSPACETX


// O
lbi R1, 0x6F
st R1, R0, 0x0


// R
lbi R1, 0x72
st R1, R0, 0x0

// L
lbi R1, 0x6C
st R1, R0, 0x0

// D
lbi R1, 0x64
st R1, R0, 0x0

// \n
lbi R1, 0x0A
st R1, R0, 0x0


// Name: [4E 61 6D 65 3A 20]
// N
lbi R1, 0x4E
st R1, R0, 0x0

// A
lbi R1, 0x61
st R1, R0, 0x0


// Wait for TX buffer to clear
JAL .WAITFORSPACETX


// M
lbi R1, 0x6D
st R1, R0, 0x0

// E
lbi R1, 0x65
st R1, R0, 0x0

// :
lbi R1, 0x3A
st R1, R0, 0x0

// [space]
lbi R1, 0x20
st R1, R0, 0x0


// Wait for TX buffer to clear
JAL .WAITFORSPACETX


// Beginning of array to store name
lbi R5, 0x00
slbi R5, 0x00

// Current Index of array
lbi R6, 0x00
slbi R6, 0x00


.INPUTLOOP:
ld R1, R0, 0
st R1, R0, 0x0
st R1, R6, 0x0
addi R6, R6, 0x1
SUBI R1, R1, 0x0A
BEQZ R1, .INPUTLOOP

// Null terminator
lbi R3, 0x00
st R3, R6, 0x0


// Wait for TX buffer to clear
JAL .WAITFORSPACETX

// Print Hello
// \n
lbi R1, 0x0A
st R1, R0, 0x0

// H
lbi R1, 0x48
st R1, R0, 0x0

// E
lbi R1, 0x65
st R1, R0, 0x0

// L
lbi R1, 0x6C
st R1, R0, 0x0

// L
lbi R1, 0x6C
st R1, R0, 0x0

// O
lbi R1, 0x6F
st R1, R0, 0x0

// [space]
lbi R1, 0x20
st R1, R0, 0x0


// Current Index of array
lbi R6, 0x00
slbi R6, 0x00

.OUTPUTLOOP:
// Wait for TX buffer to clear
JAL .WAITFORSPACETX

st R1, R0, 1
ld R1, R0, 0x0
SUBI R1, R1, 0x00
BEQZ R1, .OUTPUTLOOP




.WAITFORSPACETX:
LD R3, R0, 0x1
SRLI R3, R3, 4
SUBI R3, R3, 8
BNEZ R3, .WAITFORSPACETX
JR R7, 0


.WAITFORRX:
LD R3, R0, 0x1
// Clear out top 4 bits
SLLI R3, R3, 4
SRLI R3, R3, 4
BEQZ R3, .WAITFORRX
JR R7, 0




