; homex.g - Home X axis, then switch X into composite closed-loop (T1)
; X endstop at low end, on 41.io0.in
;
; ============================================================================
; ONE-TIME setup (run MANUALLY once per motor + encoder + 1HCL combination,
; ideally with the motor decoupled from the drive). The result is saved to the
; 1HCL flash, so it must NOT be run on every boot and is NOT in this file:
;   M569 P41.0 D4       ; enter closed loop
;   M569.6 P41.0 V2     ; absolute magnetic-encoder calibration (one-time only)
;   M569 P41.0 D2       ; back to open loop until homed
;
; TUNING workflow (R/I/D in the M569.1 line in config.g are only a start point):
;   - Use the Duet Closed Loop plugin / M569.5 to capture target vs measured steps.
;   - To bias toward slow "integral trim" behaviour on this belt axis: lower R and
;     raise I gradually, watching for oscillation. Keep D at 0.
;   - See https://docs.duet3d.com/User_manual/Tuning/Duet_3_1HCL_tuning
; ============================================================================

M569 P41.0 D2               ; Ensure open-loop mode for homing
M564 H0                     ; Allow movement without all axes homed
G91                         ; Relative positioning
G1 H1 X-650 F3000           ; Move X towards min endstop at 3000mm/min
G1 X5 F3000                 ; Back off 5mm
G1 H1 X-10 F300             ; Slowly approach endstop for accuracy
G90                         ; Absolute positioning
G92 X0                      ; Set current position as X=0

; --- Switch X into composite closed-loop ---
G1 X50 F3000                ; Move to a safe position clear of the endstop
M400                        ; Wait for the move to complete
G4 P200                     ; Let the motor settle
M569 P41.0 D4               ; Enable full closed-loop (uses the M569.1 config in config.g)
M569.6 P41.0 V1             ; Polarity detection + zeroing (must run every power-up)
