// just indefinitely reads state of switches and
// writes back out to LEDs
lbi r1, 0xC0
slbi r1, 0x00
.loop:
ld r2, r1, 1
st r2, r1, 0
j .loop