; homez.g - Home Z axis
; Z endstop at high end, on 44.io0.in

M564 H0                     ; Allow movement without all axes homed
G91                          ; Relative positioning
G1 H1 Z150 F600             ; Move Z up (towards endstop) at 600mm/min, stop at endstop
G1 Z-5 F600                 ; Back off 5mm
G1 H1 Z10 F120              ; Move slowly back to endstop for accuracy
G90                          ; Absolute positioning
G92 Z0                       ; Set current position as Z=0
