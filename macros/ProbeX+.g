; ProbeX+.g - Probe in the X+ direction with the touch probe (T0, probe K1) at the
; current position, report the measured X of the touched surface in the CURRENTLY
; ACTIVE work coordinate system, and offer to set it to a given X value.
;
; The stylus ball diameter comes from global.probeBallDia (defined centrally in
; config.g); the surface position is compensated by the ball radius: probing in
; X+ touches the surface with the +X side of the ball, so
;   surface = ball center + ball radius.
;
; Probing uses G38.2 (straight probe, stop on trigger, error if it does not
; trigger, no datum change, no report popup) at F600, matching ToolProbe.g.
;
; Usage: jog the probe ball a few mm away from the surface (on its -X side, ball
; below the workpiece top edge), then run:
;   M98 P"ProbeX+.g"       ; input dialog defaults to X0
;   M98 P"ProbeX+.g" S10   ; input dialog defaults to X10
; An input field shows the target X (default 0): press OK to set the touched
; surface to that value (edit it first if desired), or Cancel to just close.

if state.currentTool != 0
    abort "ProbeX+.g: select the touch probe with T0 (and calibrate it) before probing."
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "ProbeX+.g: home all axes (G28) before probing."

var targetX = {exists(param.S) ? param.S : 0}
var retract = 10
var ballR = {global.probeBallDia / 2}

M400                    ; ensure any previous motion has finished

; Probe toward machine X max; stop on the probe trigger, change no datum
G53 G38.2 K1 X{move.axes[0].max} F600

; Ball center stopped at the trigger point; the surface is one ball radius further +X
var measuredX = {move.axes[0].userPosition + var.ballR}

G91
G1 X{-var.retract} F600 ; retract away from the surface before showing the dialog
G90

echo "Measured X (current work coordinate system): ", var.measuredX

; Input dialog: enter the X value the touched surface should be set to (default
; var.targetX). OK sets it; Cancel terminates the macro and changes nothing.
M291 P{"Measured X = " ^ var.measuredX ^ " mm (current WCS). Enter the X value the touched surface should be set to:"} R"Probe X+" S6 F{var.targetX} J1

; Ball center now sits ballR + retract away from the surface in -X
G10 L20 X{input - var.ballR - var.retract}
echo "Probed surface set to X", input, "in the current work coordinate system."
