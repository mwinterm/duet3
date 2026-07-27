; CalibrateX.g - Report X steps/mm (M92) using the linear scale on the 1HCL (CAN 41).
;
; Single run:
;   1) moves to X min (final 2 mm approached in +X to take up backlash), runs M122 B41
;   2) moves to X max (same +X direction, so backlash cancels), runs M122 B41 again
;   3) asks you for the two signed 'position' values from the M122 reports, then
;      reports the suggested new M92 value.
;
; Use the signed "position" value on the "Closed loop driver 0 ..." line of each
; M122 B41 report - NOT the unsigned 16-bit "raw count", which wraps at 65536.
;
; Optional parameter: C<counts per mm> of the scale (default 200 = 5 um scale)
; Prerequisite: encoder configured on the 1HCL, e.g. M569.1 P41.0 T2 C3000 S200
;
; REPORT-ONLY: M92 is not changed. Copy the reported value into the M92 X line
; in config.g, then re-run config (M98 P"config.g") and re-home X.

if !move.axes[0].homed
    abort "CalibrateX.g: home X (G28 X) before calibrating."

var cpm = {exists(param.C) ? param.C : 200}     ; scale counts per mm
var startX = move.axes[0].min + 2               ; +2 so the start can be approached in +X
var endX = move.axes[0].max

; --- Position 1: near X min ---
M400
G53 G0 X{move.axes[0].min}
G53 G1 X{var.startX} F600                       ; final approach in +X
M400
M122 B41
M291 P"Enter the signed 'position' value from the M122 B41 report above (at X min)" R"CalibrateX 1/2" S5 L-2000000000 H2000000000
var count1 = input

; --- Position 2: X max ---
G53 G0 X{var.endX} F3000
M400
M122 B41
M291 P"Enter the signed 'position' value from the M122 B41 report above (at X max)" R"CalibrateX 2/2" S5 L-2000000000 H2000000000
var count2 = input

; --- Compute and report ---
var commanded = var.endX - var.startX
var measured = {abs(var.count2 - var.count1) / var.cpm}
if var.measured < 0.5 * var.commanded || var.measured > 1.5 * var.commanded
    abort {"CalibrateX.g: measured " ^ var.measured ^ " mm for a " ^ var.commanded ^ " mm move - implausible, check the readings."}

var oldSteps = move.axes[0].stepsPerMm
var newSteps = var.oldSteps * var.commanded / var.measured
var errPct = {(var.measured - var.commanded) / var.commanded * 100}

echo "Commanded:", var.commanded, "mm  Measured:", var.measured, "mm  Error:", var.errPct, "%"
echo "Old steps/mm:", var.oldSteps, " Suggested: M92 X" ^ var.newSteps
M291 P{"Old M92 X" ^ var.oldSteps ^ " -> suggested M92 X" ^ var.newSteps ^ " (error " ^ var.errPct ^ " %). M92 NOT changed - edit config.g to apply."} R"CalibrateX result" S2