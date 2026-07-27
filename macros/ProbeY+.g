; ProbeY+.g - Probe in the Y+ direction with the touch probe (T0, probe K1) at the
; current position, report the measured Y of the touched surface in the CURRENTLY
; ACTIVE work coordinate system, and offer to set it to a given Y value.
;
; The stylus ball diameter comes from global.probeBallDia (defined centrally in
; config.g); the surface position is compensated by the ball radius: probing in
; Y+ touches the surface with the +Y side of the ball, so
;   surface = ball center + ball radius.
;
; Probing uses G38.2 (straight probe, stop on trigger, error if it does not
; trigger, no datum change, no report popup) at F600, matching ToolProbe.g.
;
; Usage: jog the probe ball a few mm away from the surface (on its -Y side, ball
; below the workpiece top edge), then run:
;   M98 P"ProbeY+.g"       ; input dialog defaults to Y0
;   M98 P"ProbeY+.g" S10   ; input dialog defaults to Y10
; An input field shows the target Y (default 0): press OK to set the touched
; surface to that value (edit it first if desired), or Cancel to just close.

if state.currentTool != 0
    abort "ProbeY+.g: select the touch probe with T0 (and calibrate it) before probing."
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "ProbeY+.g: home all axes (G28) before probing."

var targetY = {exists(param.S) ? param.S : 0}
var retract = 10
var ballR = {global.probeBallDia / 2}

M400                    ; ensure any previous motion has finished

; Probe toward machine Y max; stop on the probe trigger, change no datum
G53 G38.2 K1 Y{move.axes[1].max} F600

; Ball center stopped at the trigger point; the surface is one ball radius further +Y
var measuredY = {move.axes[1].userPosition + var.ballR}

G91
G1 Y{-var.retract} F600 ; retract away from the surface before showing the dialog
G90

echo "Measured Y (current work coordinate system): ", var.measuredY

; Input dialog: enter the Y value the touched surface should be set to (default
; var.targetY). OK sets it; Cancel terminates the macro and changes nothing.
M291 P{"Measured Y = " ^ var.measuredY ^ " mm (current WCS). Enter the Y value the touched surface should be set to:"} R"Probe Y+" S6 F{var.targetY} J1

; Ball center now sits ballR + retract away from the surface in -Y
G10 L20 Y{input - var.ballR - var.retract}
echo "Probed surface set to Y", input, "in the current work coordinate system."
