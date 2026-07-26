; probe_z.g - Probe the top of the workpiece with the Z touch probe (K1) at the
; current XY position and set that surface as Z0 for the current work coordinate
; system.
;
; RRF already has a built-in command for measuring Z height with a probe: G30.
; With no S parameter, G30 Kn probes down and, when the probe triggers, sets the
; current Z position to the calibrated trigger height (the G31 K1 Z offset set
; by calibrate_touch_probe.g), correctly compensating for the probe's own
; thickness/standoff. This macro wraps that in the usual safety checks, then
; declares the probed surface as the new Z0 and retracts for clearance.
;
; Usage: jog the touch probe until it is a few mm above the top of the
; workpiece at the XY position you want to zero, then run:
;   M98 P"probe_z.g"

if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "probe_z.g: home all axes (G28) before probing Z."

M400                    ; ensure any previous motion has finished

G30 K1                  ; probe down with the touch probe; sets current Z to the
                         ; calibrated trigger height when the probe triggers
G92 Z0                  ; declare the probed surface as the new Z0

G91
G1 Z10 F600             ; retract for clearance after zeroing
G90

echo "Z zeroed. New Z0 set at the probed surface (current work coordinate system)."
