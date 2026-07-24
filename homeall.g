; homeall.g - Home all axes
;
; Z endstop is at the HIGH end, so Z is homed FIRST to raise the tool to the top.
; This gives full clearance before X and Y move, avoiding dragging the tool across
; the work. X and Y both home to their low-end endstops.
;
; X (drive 41.0) and Y (drives 42.0:43.0) are on separate CAN expansion boards with
; independent endstops, so they are homed simultaneously in combined G1 H1 moves:
; each axis's driver stops on its own endstop without waiting for the other axis.
; The F value is chosen so Y (the longer, slower-rated axis) moves at its usual
; ~1800mm/min; X just rides along proportionally slower, costing nothing since
; Y's longer travel dominates the overall time anyway.

M564 H0                 ; Allow movement of un-homed axes

M98 P"homez.g"          ; Home Z first (raises to the top for clearance)

; Home X and Y together (tandem Y squaring still works: each of its two motors
; stops independently on its own endstop switch)
G91                       ; Relative positioning
G1 H1 X-650 Y-1930 F1900  ; Fast approach both endstops together (Y effective ~1800mm/min)
G1 X5 Y5 F3000            ; Back off a few mm on both axes
G1 H1 X-10 Y-10 F300      ; Slow re-approach both endstops for accuracy
G90                       ; Absolute positioning
G92 X0                    ; X endstop is at the low end: set current position to 0

M564 H1                 ; Re-enable axis limits
