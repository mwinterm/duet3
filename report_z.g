; report_z.g - Probe the workpiece with the Z touch probe (K1) at the current
; XY position and report the measured Z height in the CURRENTLY ACTIVE work
; coordinate system (G54, G55, ...). Retracts 10mm for clearance afterwards,
; same as probe_z.g/set_z.g (this does NOT restore the exact pre-probe
; position).
;
; NOTE: G30 Kn S-1 does NOT do what its name suggests here - RRF's source
; (GCodes4.cpp) shows it reports the raw MACHINE Z coordinate of the trigger
; point, ignoring both the active work coordinate system offset and the
; calibrated G31 K1 Z trigger height. That makes it useless for reporting a
; height relative to the current WCS (it's only meant for comparing against a
; known machine-coordinate reference point, as calibrate_touch_probe.g does).
;
; Instead, this macro performs a normal G30 K1 probe. That correctly sets the
; current Z (in the active WCS) to the calibrated trigger height, because it
; only adjusts the machine position bookkeeping, not the WCS offset itself.
; We read the resulting user Z coordinate, then retract for clearance exactly
; like probe_z.g/set_z.g do (a plain relative retract - NOT an absolute move
; back to a pre-probe position computed from a variable, since G30 redefines
; the machine's Z position mapping and an absolute "return" computed from a
; before-probe value is not safe to reuse afterwards).
;
; Usage: jog the touch probe a few mm above the surface to measure, then run:
;   M98 P"report_z.g"

if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "report_z.g: home all axes (G28) before probing Z."

M400                    ; ensure any previous motion has finished

G30 K1                  ; probe down with the touch probe; sets current Z (in
                         ; the active work coordinate system) to the
                         ; calibrated trigger height when the probe triggers

var measuredZ = move.axes[2].userPosition

G91
G1 Z10 F600             ; retract for clearance after probing
G90

echo "Measured Z (current work coordinate system): ", var.measuredZ

echo "Measured Z (current work coordinate system): ", var.measuredZ
