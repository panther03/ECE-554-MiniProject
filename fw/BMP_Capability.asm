// Load Address of BMP-X_POS into R0
lbi R0, 0xC0
slbi R0, 0x08
// Load y_pos for BMP-Y_POS into R1
lbi R1, 0x00
slbi R1, 0x50
// Load y_pos for BMP-Y_POS into R5
lbi R5, 0x00
slbi R5, 0xA0

// assume draw is not busy at the start
// Write "AF AM EG JDC MR" [28*, 3C*, 90*, 28*, 58*, 90*, 38*, 40*, 90*, 4C*, 34*, 30*, 90*, 58*, 6C*] 15
// at Xs                   [0CC, 0D9, 0E6, 0F3, 100, 10D, 11A, 127, 134, 141, 14E, 15B, 168, 175, 182]
// at Ys                   [50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50]
// A - X_POS
lbi R2, 0x00
slbi R2, 0xCC
st R2, R0, 0x0

// A - Y_POS
st R1, R0, 0x1

// A - write
lbi R2, 0x28
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// 'F' - X_POS
lbi R2, 0x00
slbi R2, 0xD9
st R2, R0, 0x0

// 'F' - write
lbi R2, 0x3C
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// ' ' - X_POS
lbi R2, 0x00
slbi R2, 0xE6
st R2, R0, 0x0

// ' ' - write
lbi R2, 0x90
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// 'A' - X_POS
lbi R2, 0x00
slbi R2, 0xF3
st R2, R0, 0x0

// 'A' - write
lbi R2, 0x28
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// 'M' - X_POS
lbi R2, 0x01
slbi R2, 0x00
st R2, R0, 0x0

// 'M' - write
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

// 'E' - X_POS
lbi R2, 0x01
slbi R2, 0x1A
st R2, R0, 0x0

// 'E' - write
lbi R2, 0x38
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// 'G' - X_POS
lbi R2, 0x01
slbi R2, 0x27
st R2, R0, 0x0

// 'G' - write
lbi R2, 0x40
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

// 'J' - X_POS
lbi R2, 0x01
slbi R2, 0x41
st R2, R0, 0x0

// 'J' - write
lbi R2, 0x4C
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// 'D' - X_POS
lbi R2, 0x01
slbi R2, 0x4E
st R2, R0, 0x0

// 'D' - write
lbi R2, 0x34
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// 'C' - X_POS
lbi R2, 0x01
slbi R2, 0x5B
st R2, R0, 0x0

// 'C' - write
lbi R2, 0x30
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// ' ' - X_POS
lbi R2, 0x01
slbi R2, 0x68
st R2, R0, 0x0

// ' ' - write
lbi R2, 0x90
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// 'M' - X_POS
lbi R2, 0x01
slbi R2, 0x75
st R2, R0, 0x0

// 'M' - write
lbi R2, 0x58
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// 'R' - X_POS
lbi R2, 0x01
slbi R2, 0x82
st R2, R0, 0x0

// 'R' - write
lbi R2, 0x6C
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// Draw mario and bucky [05, 0D, 09]
// at Xs                [040, 080, 0C0]
// at Ys                [A0, A0, A0]
// Mario - X_POS
lbi R2, 0x00
slbi R2, 0x40
st R2, R0, 0x0

// Mario - Y_POS
st R5, R0, 0x1

// Mario - write
lbi R2, 0x05
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// Walter - X_POS
lbi R2, 0x00
slbi R2, 0x80
st R2, R0, 0x0

// Walter - write
lbi R2, 0x0D
st R2, R0, 0x2

JAL .WAITFORDRAWREADY

// Bucky - X_POS
lbi R2, 0x00
slbi R2, 0xC0
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