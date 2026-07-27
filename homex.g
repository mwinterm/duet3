; homex.g - Home X axis, then switch X into rotary-only closed-loop (T3)
; X endstop at low end, on 41.io0.in
;
; ============================================================================
; ONE-TIME setup (run MANUALLY once per motor + encoder + 1HCL combination,
; with the motor FREE TO ROTATE - decouple the belt or park mid-travel with
; clearance, else the sweep loses steps and fails). Saved to the 1HCL flash, so
; it must NOT be run on every boot and is NOT in this file:
;   M569 P41.0 D4       ; enter closed loop
;   M569.6 P41.0 V2     ; absolute magnetic-encoder calibration (one-time only)
;   M569 P41.0 D2       ; back to open loop until homed
; NOTE: the encoder is ABSOLUTE (rotaryMagnetic). Do NOT use M569.6 V1 (basic
; tuning) - it errors with "not applicable to absolute encoders". Once V2 is
; stored, no per-boot tuning move is needed; simply enabling D4 uses the stored
; calibration for commutation.
;
; NOTE: this branch uses ROTARY-ONLY feedback (magnetic shaft encoder). It holds
; the motor shaft on target but does NOT correct belt/friction slip at the carriage.
; ============================================================================

M569 P41.0 D2               ; Ensure open-loop mode for homing
M564 H0                     ; Allow movement without all axes homed
G91                         ; Relative positioning
G1 H1 X-650 F3000           ; Move X towards min endstop at 3000mm/min
G1 X5 F3000                 ; Back off 5mm
G1 H1 X-10 F300             ; Slowly approach endstop for accuracy
G90                         ; Absolute positioning
G92 X0                      ; Set current position as X=0

; --- Switch X into rotary-only closed-loop ---
G1 X100 F3000                ; Move to a safe position clear of the endstop
M400                        ; Wait for the move to complete
G4 P200                     ; Let the motor settle
M569 P41.0 D4               ; Enable closed loop (absolute encoder: stored V2 calibration gives commutation; no per-boot tuning move)
