; homey.g
; called to home the Y axis (handles tandem squaring automatically with two endstops),
; then switch both Y drives into rotary-only closed-loop (T3)
;
; ============================================================================
; ONE-TIME setup (run MANUALLY once per motor + encoder + 1HCL, ideally with the
; motor decoupled). Saved to 1HCL flash, so NOT run on every boot / NOT in this file:
;   M569 P42.0 D4  / M569.6 P42.0 V2  / M569 P42.0 D2      ; Y1 abs. encoder calibration
;   M569 P43.0 D4  / M569.6 P43.0 V2  / M569 P43.0 D2      ; Y2 abs. encoder calibration
;
; NOTE: rotary-only feedback (magnetic shaft encoders) holds each motor shaft on
; target but does NOT correct belt/friction slip at the carriage.
; ============================================================================

M569 P42.0 D2        ; ensure open-loop mode for homing
M569 P43.0 D2
G91                  ; relative positioning
G1 H1 Y-1930 F1800   ; move quickly to Y axis endstops and stop there (first pass)
G1 Y5 F6000          ; go back a few mm
G1 H1 Y-10 F360      ; move slowly to Y axis endstops once more (second pass)
G90                  ; absolute positioning

; --- Switch Y into rotary-only closed-loop (both tandem drives) ---
G1 Y100 F3000         ; move to a safe position clear of the endstops
M400                 ; wait for the move to complete
G4 P200              ; let the motors settle
M569 P42.0 D4        ; enable closed loop on Y1 (absolute encoder: stored V2 calibration; no per-boot tuning)
M569 P43.0 D4        ; enable closed loop on Y2
