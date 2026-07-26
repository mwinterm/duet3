; ProbeY-.g - Probe in the Y- direction with the touch probe (T0, probe K1) at the
; current position, report the measured Y of the touched surface in the CURRENTLY
; ACTIVE work coordinate system, and offer to set it to a given Y value.
;
; The stylus ball diameter comes from global.probeBallDia (defined centrally in
; config.g); the surface position is compensated by the ball radius: probing in
; Y- touches the surface with the -Y side of the ball, so
;   surface = ball center - ball radius.
;
; Probing uses G38.2 (straight probe, stop on trigger, error if it does not
; trigger, no datum change, no report popup) at F600, matching ToolProbe.g.
;
; Usage: jog the probe ball a few mm away from the surface (on its +Y side, ball
; below the workpiece top edge), then run:
;   M98 P"ProbeY-.g"       ; "Set Y" makes the touched surface Y0
;   M98 P"ProbeY-.g" S10   ; "Set Y" makes the touched surface Y10

if state.currentTool != 0
    abort "ProbeY-.g: select the touch probe with T0 (and calibrate it) before probing."
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "ProbeY-.g: home all axes (G28) before probing."

var targetY = {exists(param.S) ? param.S : 0}
var retract = 10
var ballR = {global.probeBallDia / 2}

M400                    ; ensure any previous motion has finished

; Probe toward machine Y min; stop on the probe trigger, change no datum
G53 G38.2 K1 Y{move.axes[1].min} F600

; Ball center stopped at the trigger point; the surface is one ball radius further -Y
var measuredY = {move.axes[1].userPosition - var.ballR}

G91
G1 Y{var.retract} F600  ; retract away from the surface before showing the dialog
G90

M291 P{"Measured Y = " ^ var.measuredY ^ " mm (current WCS)."} R"Probe Y-" S4 K{"Set Y" ^ var.targetY, "Close"}

if input == 0
    ; Ball center now sits ballR + retract away from the surface in +Y
    G10 L20 Y{var.targetY + var.ballR + var.retract}
    echo "Probed surface set to Y", var.targetY, "in the current work coordinate system."
else
    echo "Measured Y (current work coordinate system): ", var.measuredY
