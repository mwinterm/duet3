; CalibrateY.g - Report Y steps/mm (M92) using the linear scales on both Y 1HCLs.
; Y1 = CAN 42, Y2 = CAN 43; the axis is driven in tandem (M584 Y42.0:43.0), so every
; move drives both motors and both scales measure the same physical travel.
; M92 is per AXIS, so the suggested value is the average of the two scales; the
; difference between them is a measure of gantry drive mismatch (racking).
;
; Single run:
;   1) moves to Y min (final 2 mm approached in +Y to take up backlash),
;      runs M122 B42 (asks for the value), then M122 B43 (asks for the value)
;   2) moves to Y max (same +Y direction, so backlash cancels) and does the same
;   3) reports the measurement from each scale and the averaged suggested M92 Y.
;
; Use the signed "position" value on the "Closed loop driver 0 ..." line of each
; M122 report - NOT the unsigned 16-bit "raw count", which wraps at 65536.
;
; Optional parameter: C<counts per mm> of the scales (default 200 = 5 um scale)
; Prerequisite (in config.g): M569.1 P42.0 T2 C3000 S200 and M569.1 P43.0 T2 C3000 S200
;
; REPORT-ONLY: M92 is not changed. Copy the reported average into the M92 Y line
; in config.g, then re-run config (M98 P"config.g") and re-home Y.

if !move.axes[1].homed
    abort "CalibrateY.g: home Y (G28 Y) before calibrating."

var cpm = {exists(param.C) ? param.C : 200}     ; scale counts per mm
var startY = move.axes[1].min + 2               ; +2 so the start can be approached in +Y
var endY = move.axes[1].max

; --- Position 1: near Y min ---
M400
G53 G0 Y{move.axes[1].min}
G53 G1 Y{var.startY} F600                       ; final approach in +Y
M400
M122 B42
M291 P"Y1 (board 42): enter the signed 'position' value from the M122 B42 report above (at Y min)" R"CalibrateY 1/4" S5 L-2000000000 H2000000000
var count1a = input
M122 B43
M291 P"Y2 (board 43): enter the signed 'position' value from the M122 B43 report above (at Y min)" R"CalibrateY 2/4" S5 L-2000000000 H2000000000
var count1b = input

; --- Position 2: Y max ---
G53 G0 Y{var.endY} F3000
M400
M122 B42
M291 P"Y1 (board 42): enter the signed 'position' value from the M122 B42 report above (at Y max)" R"CalibrateY 3/4" S5 L-2000000000 H2000000000
var count2a = input
M122 B43
M291 P"Y2 (board 43): enter the signed 'position' value from the M122 B43 report above (at Y max)" R"CalibrateY 4/4" S5 L-2000000000 H2000000000
var count2b = input

; --- Compute and report ---
var commanded = var.endY - var.startY
var measured1 = {abs(var.count2a - var.count1a) / var.cpm}
var measured2 = {abs(var.count2b - var.count1b) / var.cpm}
if var.measured1 < 0.5 * var.commanded || var.measured1 > 1.5 * var.commanded
    abort {"CalibrateY.g: Y1 measured " ^ var.measured1 ^ " mm for a " ^ var.commanded ^ " mm move - implausible, check the readings."}
if var.measured2 < 0.5 * var.commanded || var.measured2 > 1.5 * var.commanded
    abort {"CalibrateY.g: Y2 measured " ^ var.measured2 ^ " mm for a " ^ var.commanded ^ " mm move - implausible, check the readings."}

var oldSteps = move.axes[1].stepsPerMm
var newSteps1 = var.oldSteps * var.commanded / var.measured1
var newSteps2 = var.oldSteps * var.commanded / var.measured2
var newStepsAvg = {(var.newSteps1 + var.newSteps2) / 2}
var errPct1 = {(var.measured1 - var.commanded) / var.commanded * 100}
var errPct2 = {(var.measured2 - var.commanded) / var.commanded * 100}

echo "Commanded:", var.commanded, "mm"
echo "Y1 (board 42): measured", var.measured1, "mm  error", var.errPct1, "%  -> steps/mm", var.newSteps1
echo "Y2 (board 43): measured", var.measured2, "mm  error", var.errPct2, "%  -> steps/mm", var.newSteps2
echo "Y1/Y2 difference:", {var.measured1 - var.measured2}, "mm over", var.commanded, "mm (gantry drive mismatch)"
echo "Old steps/mm:", var.oldSteps, " Suggested (average): M92 Y" ^ var.newStepsAvg
M291 P{"Old M92 Y" ^ var.oldSteps ^ " -> Y1: " ^ var.newSteps1 ^ ", Y2: " ^ var.newSteps2 ^ ", average: M92 Y" ^ var.newStepsAvg ^ ". M92 NOT changed - edit config.g to apply."} R"CalibrateY result" S2
