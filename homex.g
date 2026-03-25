; homex.g - Home X axis
; X endstop at low end, on 41.io0.in

M569 P41.0 D0                ; Ensure open-loop mode for homing
M564 H0                     ; Allow movement without all axes homed
G91                          ; Relative positioning
G1 H1 X-650 F3000           ; Move X towards min endstop at 3000mm/min
G1 X5 F3000                 ; Back off 5mm
G1 H1 X-10 F300             ; Slowly approach endstop for accuracy
G90                          ; Absolute positioning
G92 X0                       ; Set current position as X=0

; --- Closed-loop activation ---
G1 X50 F3000                ; Move to safe position away from endstop
M400                         ; Wait for move to complete
G4 P200                      ; Let motor settle
M569 P41.0 D4               ; Enable full closed-loop mode
; NOTE: M569.6 P41.0 V2 (magnetic encoder calibration) only needs to be run ONCE ever.
;       After first run, calibration is saved to 1HCL flash. Do not run on every boot.
; Run M569.6 P41.0 V1 after V2 is complete (linear scale calibration, runs every boot):
M569.6 P41.0 V1             ; Calibrate linear scale to magnetic encoder (~20 steps each way)
