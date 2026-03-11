; homex.g - Home X axis
; X endstop at low end, on 41.io0.in

M564 H0                     ; Allow movement without all axes homed
G91                          ; Relative positioning
G1 H1 X-650 F3000           ; Move X towards min endstop at 3000mm/min
G1 X5 F3000                 ; Back off 5mm
G1 H1 X-10 F300             ; Slowly approach endstop for accuracy
G90                          ; Absolute positioning
G92 X0                       ; Set current position as X=0
