; ProbeZ-.g - Probe in the Z- direction with the touch probe (T0, probe K1) at the
; current XY position, report the measured Z height in the CURRENTLY ACTIVE work
; coordinate system, and offer to set the probed surface to a given Z value.
;
; Replaces the former probe_z.g / set_z.g / report_z.g macros.
;
; Requires the touch probe to be in the spindle, selected as T0 and calibrated
; with ToolProbe.g (probe length lives in T0's tool offset; G31 K1 Z is 0).
;
; Probing uses G38.2 (straight probe toward the workpiece, stop on trigger,
; error if it does not trigger). Unlike G30 it changes no datum and prints no
; "Stopped at height" message. F600 matches the G30 fast probing speed used by
; the T0 calibration in ToolProbe.g, so the trigger latency cancels out.
; Setting Z uses G10 L20, which adjusts the active WCS so the probed surface
; reads the requested value - so any setter-measured cutting tool then cuts at
; the right depth.
;
; Usage: jog the touch probe a few mm above the surface, then run:
;   M98 P"ProbeZ-.g"       ; input dialog defaults to Z0
;   M98 P"ProbeZ-.g" S10   ; input dialog defaults to Z10
;
; A dialog shows the measured height with an input field (default = target Z):
; press OK to set the probed surface to the entered value in the active WCS
; (edit it first if desired), or Cancel to just report and change nothing.

if state.currentTool != 0
    abort "ProbeZ-.g: select the touch probe with T0 (and calibrate it) before probing."
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "ProbeZ-.g: home all axes (G28) before probing Z."

var targetZ = {exists(param.S) ? param.S : 0}
var retract = 10

M400                    ; ensure any previous motion has finished

; Probe down toward machine Z min; stop on the probe trigger, change no datum,
; no report. G38.2 raises an error if the probe does not trigger.
G53 G38.2 K1 Z{move.axes[2].min} F600

; Machine stopped at the trigger point: userPosition already includes the T0
; tool offset and the active WCS offset, so it IS the surface height in the WCS
var measuredZ = move.axes[2].userPosition

G91
G1 Z{var.retract} F600  ; retract for clearance before showing the dialog
G90

echo "Measured Z (current work coordinate system): ", var.measuredZ

; Input dialog: enter the Z value the probed surface should be set to (default
; var.targetZ). OK sets it; Cancel terminates the macro and changes nothing.
M291 P{"Measured Z = " ^ var.measuredZ ^ " mm (current WCS). Enter the Z value the probed surface should be set to:"} R"Probe Z" S6 F{var.targetZ} J1

; Current position is var.retract above the surface; make the surface read the entered value
G10 L20 Z{input + var.retract}
echo "Probed surface set to Z", input, "in the current work coordinate system."
