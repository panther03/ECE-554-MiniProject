// just indefinitely reads state of switches and
// writes back out to LEDs
.loop:
slbi r1, 0xC0
lbi r1, 0x00
ld r2, r1, 1
st r2, r1, 0
j .loop