; homey.g
; called to home the Y axis (handles tandem squaring automatically with two endstops)
;
G91                  ; relative positioning
G1 H1 Y-1930 F1800   ; move quickly to Y axis endstops and stop there (first pass)
G1 Y5 F6000          ; go back a few mm
G1 H1 Y-10 F360      ; move slowly to Y axis endstops once more (second pass)
G90                  ; absolute positioning
