; calibrate_touch_probe.g - Calibrate the Z touch probe trigger height (probe "length")
;
; Probes a known reference surface at machine X30 Y42 whose top is at machine Z = var.refZ,
; then sets probe K1's trigger height (G31 K1 Z) so that G30 K1 reports correct Z afterwards.
;
; Run with all axes homed:  M98 P"calibrate_touch_probe.g"

; --- Reference surface (machine coordinates) ---
var probeX = 30
var probeY = 45
var refZ   = 15          ; known machine Z of the reference surface top
var clearance = 10       ; how far above the surface to rapid to before probing (mm)

; --- Safety checks ---
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "calibrate_touch_probe.g: home all axes (G28) before calibrating the touch probe."

M400                             ; ensure any previous motion has finished

; Go to the top in Z first, move over the surface, then rapid down close to it before probing.
; A homed G30 only probes a short distance toward the axis minimum, so we must start near the
; surface - otherwise the probing move ends before reaching it.
G90                              ; absolute positioning
G53 G0 Z{move.axes[2].max}       ; raise to Z max (machine coords) for clearance
G53 G0 X{var.probeX} Y{var.probeY}          ; move over the reference surface (machine coords)
G53 G0 Z{var.refZ + var.clearance}          ; rapid down to just above the reference surface

; Probe down with the touch probe (K1); report machine Z at trigger without altering position
G30 K1 S-1

; Machine Z of the controlled point when the probe triggered
var trigZ = move.axes[2].machinePosition

; Trigger height = how far the controlled point sits above the surface when the probe fires
var trigHeight = { var.trigZ - var.refZ }

; Apply the calibrated trigger height to probe 1
G31 K1 P500 X0 Y0 Z{var.trigHeight}

; Persist tool offsets (P10) and probe trigger heights (P31) to config-override.g
M500 P10:31

; Retract back to the top
G53 G0 Z{move.axes[2].max}

echo "Touch probe K1 trigger height set to", var.trigHeight, "mm (triggered at machine Z", var.trigZ, ", reference", var.refZ, ")"

; Pop up a message with the calibrated trigger height
M291 P{"Touch probe K1 calibrated. Trigger height = " ^ var.trigHeight ^ " mm"} R"Touch Probe" S1
