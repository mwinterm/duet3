; set_z.g - Probe the workpiece with the Z touch probe (K1) at the current XY
; position and set the current Z coordinate to a specified value at that
; surface (default 0 if no value is given).
;
; Uses G30 K1 to probe and correctly account for the touch probe's own
; standoff/thickness (via the calibrated G31 K1 Z offset from
; calibrate_touch_probe.g), then G92 to declare the probed surface to be at
; the requested Z value.
;
; Usage:
;   M98 P"set_z.g"      ; probe and set Z to 0 at the probed surface
;   M98 P"set_z.g" S10  ; probe and set Z to 10 at the probed surface

if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "set_z.g: home all axes (G28) before probing Z."

var targetZ = {exists(param.S) ? param.S : 0}

M400                    ; ensure any previous motion has finished

G30 K1                  ; probe down with the touch probe; sets current Z to
                         ; the calibrated trigger height when the probe
                         ; triggers
G92 Z{var.targetZ}       ; declare the probed surface as the requested Z value

G91
G1 Z10 F600             ; retract for clearance after probing
G90

echo "Z set to ", var.targetZ, " at the probed surface (current work coordinate system)."
