; homeall.g - Home all axes
;
; Z endstop is at the HIGH end, so Z is homed FIRST to raise the tool to the top.
; This gives full clearance before X and Y move, avoiding dragging the tool across
; the work. X and Y both home to their low-end endstops.

M564 H0                 ; Allow movement of un-homed axes

M98 P"homez.g"          ; Home Z first (raises to the top for clearance)
M98 P"homex.g"          ; Home X (low-end endstop)
M98 P"homey.g"          ; Home Y (tandem, low-end endstops)

M564 H1                 ; Re-enable axis limits
