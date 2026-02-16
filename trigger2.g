; trigger2.g - Emergency stop with VFD shutdown
; Sends Modbus stop command to H100 VFD before halting firmware
; This ensures the spindle stops even though M112 kills daemon.g

; Stop the VFD via Modbus
M260.1 P2 A1 F6 R512 B0
G4 P100                      ; Wait for VFD to acknowledge

; Now halt the firmware
M112
