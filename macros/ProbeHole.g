; ProbeHole.g - Probe the inside of a hole/bore with the touch probe (T0, probe K1):
; touches X+, X-, Y+, Y- and computes the hole center and diameter, then shows two
; input dialogs (default 0) to set the center X and Y in the CURRENTLY ACTIVE work
; coordinate system. Cancel the first dialog to change nothing; cancelling the
; second keeps only the X setting.
;
; Sequence (8 touches for exact diameters even when started off-center):
;   1. X pass from the start position: the midpoint of any horizontal chord gives
;      the exact hole center X (even if started off-center in Y)
;   2. Y pass at center X: exact center Y and Y diameter
;   3. X pass again at center Y: exact X diameter and refined center X
;   4. Y pass again at refined center X: refined center Y and Y diameter
; The probe ends positioned at the computed hole center.
;
; The stylus ball diameter comes from global.probeBallDia (defined centrally in
; config.g); internal measurements add one ball radius on each side.
;
; Probing uses G38.2 (straight probe, stop on trigger, error if it does not
; trigger, no datum change, no report popup) at F600, matching ToolProbe.g.
;
; Usage: jog the probe ball INTO the hole (roughly centered, ball below the hole's
; top edge), then run:  M98 P"ProbeHole.g"

if state.currentTool != 0
    abort "ProbeHole.g: select the touch probe with T0 (and calibrate it) before probing."
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "ProbeHole.g: home all axes (G28) before probing."

var ballR = {global.probeBallDia / 2}

M400                             ; ensure any previous motion has finished
G90                              ; absolute positioning

; Start position (assumed to be roughly the hole center)
var startX = move.axes[0].userPosition
var startY = move.axes[1].userPosition

; --- Pass 1: X chord from the start position -> exact center X ---
G53 G38.2 K1 X{move.axes[0].max} F600       ; touch the +X wall
var xp = {move.axes[0].userPosition + var.ballR}
G1 X{var.startX} F600                       ; back to the middle
G53 G38.2 K1 X{move.axes[0].min} F600       ; touch the -X wall
var xm = {move.axes[0].userPosition - var.ballR}
var centerX = {(var.xp + var.xm) / 2}
G1 X{var.centerX} F600                      ; move to center X

; --- Pass 2: Y at center X -> exact center Y and Y diameter ---
G53 G38.2 K1 Y{move.axes[1].max} F600       ; touch the +Y wall
var yp = {move.axes[1].userPosition + var.ballR}
G1 Y{var.startY} F600                       ; back to the middle
G53 G38.2 K1 Y{move.axes[1].min} F600       ; touch the -Y wall
var ym = {move.axes[1].userPosition - var.ballR}
var centerY = {(var.yp + var.ym) / 2}
G1 Y{var.centerY} F600                      ; move to center Y

; --- Pass 3: X again at center Y -> exact X diameter, refined center X ---
G53 G38.2 K1 X{move.axes[0].max} F600       ; touch the +X wall
var xp2 = {move.axes[0].userPosition + var.ballR}
G1 X{var.centerX} F600                      ; back to the middle
G53 G38.2 K1 X{move.axes[0].min} F600       ; touch the -X wall
var xm2 = {move.axes[0].userPosition - var.ballR}
set var.centerX = {(var.xp2 + var.xm2) / 2}
var diaX = {var.xp2 - var.xm2}
G1 X{var.centerX} F600                      ; move to refined center X

; --- Pass 4: Y again at refined center X -> exact Y diameter, refined center Y ---
G53 G38.2 K1 Y{move.axes[1].max} F600       ; touch the +Y wall
var yp2 = {move.axes[1].userPosition + var.ballR}
G1 Y{var.centerY} F600                      ; back to the middle
G53 G38.2 K1 Y{move.axes[1].min} F600       ; touch the -Y wall
var ym2 = {move.axes[1].userPosition - var.ballR}
set var.centerY = {(var.yp2 + var.ym2) / 2}
var diaY = {var.yp2 - var.ym2}

; Single reported diameter: average of the X and Y measurements
var dia = {(var.diaX + var.diaY) / 2}

; Finish at the computed hole center
G1 X{var.centerX} Y{var.centerY} F600
M400

echo "Hole center X", var.centerX, "Y", var.centerY, "; diameter", var.dia, "(current WCS)"

; Input dialogs (default 0): OK sets the hole center to the entered value in the
; current WCS; Cancel terminates the macro (cancelling the first dialog changes
; nothing, cancelling the second keeps only the X setting). The probe is sitting
; at the computed center, so G10 L20 applies directly.
M291 P{"Hole center X = " ^ var.centerX ^ ", Y = " ^ var.centerY ^ " mm, diameter = " ^ var.dia ^ " mm (current WCS). Enter the X value the hole center should be set to:"} R"Probe Hole" S6 F0 J1
G10 L20 X{input}
echo "Hole center set to X", input, "in the current work coordinate system."

M291 P{"Enter the Y value the hole center should be set to:"} R"Probe Hole" S6 F0 J1
G10 L20 Y{input}
echo "Hole center set to Y", input, "in the current work coordinate system."
