// Load Address of BMP-X_POS into R0
lbi R0, 0xC0
slbi R0, 0x08
// Load y_pos for BMP-Y_POS into R1
lbi R1, 0x00
slbi R1, 0x50

// assume draw is not busy at the start
// Write "M vs B" [58, 90, 7C, 70, 90, 2C]
// at Xs       [100, 10D, 11A, 127, 134, 141]
// at Ys          [50, 50, 50, 50, 50, 50]
// M - X_POS
lbi R2, 0x01
slbi R2, 0x00
st R2, R0, 0x0

// M - Y_POS
st R1, R0, 0x1

// M - write
lbi R2, 0x58
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// ' ' - X_POS
lbi R2, 0x01
slbi R2, 0x0D
st R2, R0, 0x0

// ' ' - write
lbi R2, 0x90
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// 'V' - X_POS
lbi R2, 0x01
slbi R2, 0x1A
st R2, R0, 0x0

// 'V' - write
lbi R2, 0x7C
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// 'S' - X_POS
lbi R2, 0x01
slbi R2, 0x27
st R2, R0, 0x0

// 'S' - write
lbi R2, 0x70
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// ' ' - X_POS
lbi R2, 0x01
slbi R2, 0x34
st R2, R0, 0x0

// ' ' - write
lbi R2, 0x90
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// 'B' - X_POS
lbi R2, 0x01
slbi R2, 0x41
st R2, R0, 0x0

// 'B' - write
lbi R2, 0x2C
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// Draw mario and bucky [05, 09]
// at Xs                [040, 180]
// at Ys                [50, 50]
// Mario - X_POS
lbi R2, 0x00
slbi R2, 0x40
st R2, R0, 0x0

// Mario - write
lbi R2, 0x05
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// Bucky - X_POS
lbi R2, 0x01
slbi R2, 0x80
st R2, R0, 0x0

// Bucky - write
lbi R2, 0x09
st R2, R0, 0x2

// finished, busy wait now
.BUSYWAIT:
J .BUSYWAIT

// This subroutine waits until the TX queue is totally empty.
.WAITFORDRAWREADY:
// load status register into r3
LD R3, R0, 0x3
BEQZ R3, .WAITFORDRAWREADY
JR R7, 0