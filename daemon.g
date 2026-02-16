; daemon.g - H100 VFD Modbus RTU spindle control
; Uses internal while loop to avoid RRF daemon.g re-scheduling delay
; H100 registers: 512=run/stop (1=fwd, 0=stop), 513=frequency (0.1Hz units)
; H100 register 544 (0x0220) = output frequency (0.1Hz units, read-only)
; Slave address 1 (F163=1), Serial channel P2 (IO1/RS485)

; Wait for spindle to be configured
if !exists(spindles)
  M99
if !exists(spindles[0])
  M99

var loopCount = 0

while true
  G4 P50

  ; Read current spindle state
  var spindleState = spindles[0].state
  var spindleRPM = spindles[0].active

  ; Calculate frequency value for H100
  ; 2-pole motor: 24000 RPM = 400 Hz, register expects 0.1 Hz units
  var freqValue = {floor(var.spindleRPM / 6 + 0.5)}

  ; Clamp frequency
  if var.freqValue > 4000
    set var.freqValue = 4000
  if var.freqValue < 0
    set var.freqValue = 0

  ; Only send commands if state or frequency changed
  if var.spindleState != global.vfdState || var.freqValue != global.vfdFreq
    if var.spindleState == "forward"
      M260.1 P2 A1 F6 R513 B{var.freqValue}
      M260.1 P2 A1 F6 R512 B1
    elif var.spindleState == "reverse"
      M260.1 P2 A1 F6 R513 B{var.freqValue}
      M260.1 P2 A1 F6 R512 B2
    else
      M260.1 P2 A1 F6 R512 B0
    set global.vfdState = var.spindleState
    set global.vfdFreq = var.freqValue

  ; Read actual output frequency from VFD every ~500ms (every 10 loops)
  set var.loopCount = {var.loopCount + 1}
  if var.loopCount >= 10
    set var.loopCount = 0
    M261.1 P2 A1 F4 R544 B1 V"vfdOutputFreq"
    if exists(var.vfdOutputFreq) && var.vfdOutputFreq != null
      ; Convert 0.1Hz units back to RPM: RPM = freq * 6
      set global.vfdActualRPM = {var.vfdOutputFreq[0] * 6}
